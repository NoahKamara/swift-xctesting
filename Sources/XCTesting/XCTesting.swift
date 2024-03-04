// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
///
import XCTestingMacros

@attached(peer, names: suffixed(_XCTest))
public macro XCTesting() = #externalMacro(module: "XCTestingMacros", type: "XCTestingMacro")


@_exported import XCTest
@_exported import Testing


@_spi(ExperimentalEventHandling) @_spi(ExperimentalTestRunning) @_spi(ExperimentalEventRecording) @_spi(ForToolsIntegrationOnly) import Testing

extension Test.ID {
    init(suite: Any.Type, testName: String) {
        var components = _typeName(suite, qualified: true)
            .split(separator: ".")
            .map(String.init)

        // If a type is extended in another module and then referenced by name, its
        // name according to the _typeName(_:qualified:) SPI will be prefixed with
        // "(extension in MODULE_NAME):". For our purposes, we never want to preserve
        // that prefix.
        if let firstComponent = components.first, firstComponent.starts(with: "(extension in ") {
            components[0] = String(firstComponent.split(separator: ":", maxSplits: 1).last!)
        }

        let moduleName = components.first ?? ""
        let nameComponents: [String] = if components.count > 0 {
            Array(components.dropFirst())
        } else {
            []
        }

        self.init(
            moduleName: moduleName,
            nameComponents: nameComponents + [testName],
            sourceLocation: nil
        )
    }
}

extension Event.Kind: CustomStringConvertible {
    var rawValue: String {
        switch self {
            case .runStarted:
                "runStarted"
            case .iterationStarted:
                "iterationStarted"
            case .planStepStarted:
                "planStepStarted"
            case .testStarted:
                "testStarted"
            case .testCaseStarted:
                "testCaseStarted"
            case .testCaseEnded:
                "testCaseEnded"
            case .expectationChecked:
                "expectationChecked"
            case .issueRecorded:
                "issueRecorded"
            case .testEnded:
                "testEnded"
            case .testSkipped:
                "testSkipped"
            case .planStepEnded:
                "planStepEnded"
            case .iterationEnded:
                "iterationEnded"
            case .runEnded:
                "runEnded"
        }
    }

    public var description: String {
        let detail = switch self {
        case .iterationStarted(let index), .iterationEnded(let index):
            "\(index)"

        case .planStepStarted(let step), .planStepEnded(let step):
            "\(step.test.id)"

        case .expectationChecked(let exp):
            "(\(exp.isPassing ? "✓" : "✕")) \(exp.evaluatedExpression)"

        case .issueRecorded(let issue):
            issue.description

        case .testSkipped(let skipInfo):
            skipInfo.localizedDescription

        default:
            String?.none
        }
        
        return if let detail {
            "[\(rawValue)] \(detail)"
        } else {
            "[\(rawValue)]"
        }
    }
}


public enum Tests {
    public static func run(suite: Any.Type?, test: String, in testCase: XCTestCase) async {
        let id = if let suite {
            Test.ID(suite: suite, testName: test)
        } else {
            Test.ID(
                moduleName: "",
                nameComponents: [test],
                sourceLocation: nil
            )
        }

        var config = Configuration()
        config.isParallelizationEnabled = false
        config.testFilter = .init(including: [id])
        await run(configuration: config, for: testCase)
    }
    
    static func run(configuration: Configuration, for testCase: XCTestCase) async {
        @Sendable
        func debugEventReporter(_ event: Event, _ context: Event.Context) {
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

        var configuration = configuration
        let oldEventHandler = configuration.eventHandler

        configuration.eventHandler = { event, context in

            debugEventReporter(event, context)

            oldEventHandler(event, context)

            guard case let .issueRecorded(issue) = event.kind else {
                return
            }

            if issue.isKnown {
                XCTExpectFailure {
                    testCase.rawValue.record(XCTIssue(issue))
                }
            } else {
                testCase.rawValue.record(XCTIssue(issue))
            }
        }

        let runner = await Runner(configuration: configuration)
        await runner.run()
    }
}

public enum TestScaffold {
    func runTests(
        options: [Event.ConsoleOutputRecorder.Option],
        configuration: Configuration
    ) async {
        let eventRecorder = Event.ConsoleOutputRecorder(options: options) { string in
            //#if !SWT_NO_FILE_IO
            //            try? FileHandle.stderr.write(string)
            //#endif
            print(string)
        }

        var configuration = configuration

        let oldEventHandler = configuration.eventHandler
        configuration.eventHandler = { event, context in
            eventRecorder.record(event, in: context)
            oldEventHandler(event, context)
        }

        let runner = await Runner(configuration: configuration)
        await runner.run()
    }
}

//
//    #if SWIFT_PM_SUPPORTS_SWIFT_TESTING
//    let message = Event.ConsoleOutputRecorder.warning(
//        "This version of Swift Package Manager supports running swift-testing tests directly. Ignoring call to \(#function).",
//        options: .for(.stderr)
//    )
//    #if SWT_TARGET_OS_APPLE
//    try? FileHandle.stderr.write(message)
//    #else
//    print(message)
//    #endif
//    #else
//    let testCase = UncheckedSendable(rawValue: testCase)
//    #if SWT_TARGET_OS_APPLE
//    let isProcessLaunchedByXcode = Environment.variable(named: "XCTestSessionIdentifier") != nil
//    #endif
//
//    var configuration = Configuration()
//    configuration.isParallelizationEnabled = false
//    configuration.testFilter = TestFilter.init(including: [])
//    configuration.eventHandler = { event, context in
//        guard case let .issueRecorded(issue) = event.kind else {
//            return
//        }
//
//    #if SWT_TARGET_OS_APPLE
//        if issue.isKnown {
//            XCTExpectFailure {
//                testCase.rawValue.record(XCTIssue(issue, processLaunchedByXcode: isProcessLaunchedByXcode))
//            }
//        } else {
//            testCase.rawValue.record(XCTIssue(issue, processLaunchedByXcode: isProcessLaunchedByXcode))
//        }
//    #else
//        // NOTE: XCTestCase.recordFailure(withDescription:inFile:atLine:expected:)
//        // does not behave as it might appear. The `expected` argument determines
//        // if the issue represents an assertion failure or a thrown error.
//        if !issue.isKnown {
//            testCase.rawValue.recordFailure(withDescription: String(describing: issue),
//                                            inFile: issue.sourceLocation?._filePath ?? "<unknown>",
//                                            atLine: issue.sourceLocation?.line ?? 0,
//                                            expected: true)
//        }
//    #endif
//    }
//
//    var options = [Event.ConsoleOutputRecorder.Option]()
//    #if !SWT_NO_FILE_IO
//    options += .for(.stderr)
//    #endif
//    if Environment.flag(named: "SWT_VERBOSE_OUTPUT") == true {
//        options.append(.useVerboseOutput)
//    }
//
//    await runTests(options: options, configuration: configuration)
//    #endif


struct UncheckedSendable<T>: RawRepresentable, @unchecked Sendable {
    var rawValue: T

    //
    // This source file is part of the Swift.org open source project
    //
    // Copyright (c) 2023 Apple Inc. and the Swift project authors
    // Licensed under Apache License v2.0 with Runtime Library Exception
    //
    // See https://swift.org/LICENSE.txt for license information
    // See https://swift.org/CONTRIBUTORS.txt for Swift project authors
    //
    init(rawValue: T) {
        self.rawValue = rawValue
    }
}


extension XCTSourceCodeContext {
    convenience init(_ sourceContext: SourceContext) {
        let addresses = sourceContext.backtrace?.addresses.map { $0 as NSNumber } ?? []
        let sourceLocation = sourceContext.sourceLocation.map { sourceLocation in
            XCTSourceCodeLocation(
                filePath: sourceLocation._filePath,
                lineNumber: sourceLocation.line
            )
        }
        self.init(callStackAddresses: addresses, location: sourceLocation)
    }
}


// MARK: - CustomStringConvertible, CustomDebugStringConvertible

extension UncheckedSendable: CustomStringConvertible where T: CustomStringConvertible {
    var description: String {
        rawValue.description
    }
}

extension UncheckedSendable: CustomDebugStringConvertible where T: CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue.debugDescription
    }
}


extension XCTIssue {
    init(_ issue: Issue) {
        var error = issue.error

        let issueType: XCTIssue.IssueType
        switch issue.kind {
            case .expectationFailed, .confirmationMiscounted:
                issueType = .assertionFailure
            case .errorCaught:
                issueType = .thrownError
            case let .timeLimitExceeded(timeLimitComponents: timeLimitComponents):
                issueType = .thrownError
                if error == nil {
                    error = TimeoutError(timeLimit: timeLimitComponents)
                }
            case .unconditional:
                issueType = .assertionFailure
            case .knownIssueNotRecorded:
                issueType = .unmatchedExpectedFailure
            case .apiMisused, .system:
                issueType = .system
        }

        self.init(
            type: issueType,
            compactDescription: String(describing: issue),
            detailedDescription: nil,
            sourceCodeContext: XCTSourceCodeContext(issue.sourceContext),
            associatedError: error,
            attachments: []
        )
    }
}

struct TimeoutError: Error, CustomStringConvertible {
    typealias TimeValue = (seconds: Int64, attoseconds: Int64)

    /// The time limit exceeded by the test that timed out.
    var timeLimit: TimeValue

    var seconds: Int64 { timeLimit.seconds }
    var attoseconds: Int64 { timeLimit.attoseconds }

    init(timeLimit: TimeValue) {
        self.timeLimit = timeLimit
    }

    var description: String {
        let (secondsFromAttoseconds, attosecondsRemaining) = attoseconds.quotientAndRemainder(dividingBy: 1_000_000_000_000_000_000)
        let seconds = seconds + secondsFromAttoseconds
        var milliseconds = attosecondsRemaining / 1_000_000_000_000_000
        if seconds == 0 && milliseconds == 0 && attosecondsRemaining > 0 {
            milliseconds = 1
        }

        return withUnsafeTemporaryAllocation(of: CChar.self, capacity: 512) { buffer in
            withVaList([CLongLong(seconds), CInt(milliseconds)]) { args in
                _ = vsnprintf(buffer.baseAddress!, buffer.count, "%lld.%03d seconds", args)
            }
            return String(cString: buffer.baseAddress!)
        }
    }
}

