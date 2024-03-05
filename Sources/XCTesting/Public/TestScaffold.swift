//
//  File.swift
//  
//
//  Created by Noah Kamara on 04.03.24.
//

@_spi(ExperimentalEventHandling) @_spi(ExperimentalTestRunning) @_spi(ForToolsIntegrationOnly) import Testing

public enum TestScaffold {
    /// Run a test identified by a test and optional suit
    ///
    /// This Implementation will be used by the code generated from the ``XCTesting/XCTesting()`` macro
    ///
    /// ```swift
    /// @XCTesting
    /// @Suite
    /// struct MyTests {
    ///     @Test(arguments: [1,2,3])
    ///     func example(arg: Int) {
    ///         #expect(arg > 0
    ///     }
    /// }
    ///
    /// // Expansion from XCTesting
    /// class MyTests_XCTest: XCTestCase {
    ///     func testExample() async throws {
    ///         try await Tests.run(suite: MyTests.self, testName: "testExample(arg:)", hostedBy: self)
    ///     }
    /// }
    /// ```
    ///
    /// if no `suite` is specified, a standalone test identifierd only by `testName` is called
    ///
    ///    /// @XCTesting
    /// @Suite
    /// struct MyTests {
    ///     @Test(arguments: [1,2,3])
    ///     func example(arg: Int) {
    ///         #expect(arg > 0)
    ///     }
    /// }
    ///
    /// // Expansion from XCTesting
    /// class standaloneExample_XCTest: XCTestCase {
    ///     func testStandaloneExample() async throws {
    ///         try await Tests.run(testName: "testExample(arg:)", hostedBy: self)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - suite: a type  marked with @Suite
    ///   - testName: the name of a function containing a test
    ///   - testCase: The XCTestCase that will host the test
    public static func run(
        suite: Any.Type? = nil,
        testName: String,
        hostedBy testCase: XCTestCase,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column
    ) async throws {
        let testID = if let suite {
            Test.ID(suite: suite, testName: testName)
        } else {
            Test.ID(fileID: fileID, testName: testName)
        }

        var config = Configuration()

        // Set Filter so that run only contains our test
        config.testFilter = .init(including: [testID])

        try await run(configuration: config, hostedBy: testCase)
    }


    /// Run a configuration hosted by a testCase
    /// - Parameters:
    ///   - configuration: Testing Configuration
    ///   - testCase: XCTestCase hosting the test
    static func run(configuration: Configuration, hostedBy testCase: XCTestCase) async throws {
        @Sendable
        func debugEventReporter(_ event: Event, _ context: Event.Context) {
            print(event.kind)
            switch event.kind {
                case .testStarted, .testEnded, .testCaseStarted, .testCaseEnded:
                    break
                default:
                    return
            }

            let fqdn = if let testID = event.testID { ([testID.moduleName]+testID.nameComponents) } else { [String]() }

            let args = if let testCase = context.testCase, testCase.isParameterized {
                testCase
                    .arguments
                    .map({ arg in
                        if arg.parameter.firstName != "_" {
                            "\(arg.parameter.firstName): \(arg.value)"
                        } else {
                            "\(arg.value)"
                        }
                    })
                    .joined(separator: ", ")
            } else { String?.none }

            print(fqdn.joined(separator: ".") + " " + event.kind.description + " " + (args ?? ""))
        }
        let testCase = UncheckedSendable(rawValue: testCase)


        let oldEventHandler = configuration.eventHandler

        let stream = AsyncStream<(Event, Event.Context)> { continuation in
            var configuration = configuration

            configuration.eventHandler = { event, context in
                debugEventReporter(event, context)

                continuation.yield((event, context))
            }



            continuation.onTermination = { _ in
                continuation.finish()
            }

            let config = configuration

            Task {
                let runner = await Runner(configuration: config)
                await runner.run()
                continuation.finish()
            }
        }


        for await (event, context) in stream {
#if TESTING_ENABLED
            debugEventReporter(event, context)
#endif

            oldEventHandler(event, context)

            switch event.kind {
                case .issueRecorded(let issue):
                    if issue.isKnown {
                        XCTExpectFailure {
                            testCase.rawValue.record(XCTIssue(issue))
                        }
                    } else {
                        testCase.rawValue.record(XCTIssue(issue))
                    }

                case .testSkipped(let skipInfo):
                    throw XCTSkip(skipInfo.comment.testDescription)

                default:
                    break
            }
        }
    }
}
