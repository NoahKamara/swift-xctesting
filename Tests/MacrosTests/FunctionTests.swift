import MacroTesting
import XCTest
@testable import XCTestingMacros

final class FunctionTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(
//            isRecording: true,
            macros: ["XCTesting": XCTestingMacro.self]
        ) {
            super.invokeTest()
        }
    }

    func testEmptySuite() {
        assertMacro {
            functionWrapper(TestFunction.basic)
        } expansion: {
            """
            @Test
            func basic() {}

            final class basic_XCTest: XCTestCase {
                func testBasic() async throws {
                    try await TestScaffold.run(testName: "basic()", hostedBy: self)
                }
            }
            """
        }
    }

    func testAsync() {
        assertMacro {
            functionWrapper(TestFunction.async)
        } expansion: {
            """
            @Test
            func async() async {}

            final class async_XCTest: XCTestCase {
                func testAsync() async throws {
                    try await TestScaffold.run(testName: "async()", hostedBy: self)
                }
            }
            """
        }
    }

    func testThrowing() {
        assertMacro {
            functionWrapper(TestFunction.throwing)
        } expansion: {
            """
            @Test
            func throwing() throws {}

            final class throwing_XCTest: XCTestCase {
                func testThrowing() async throws {
                    try await TestScaffold.run(testName: "throwing()", hostedBy: self)
                }
            }
            """
        }
    }

    func testAsyncThrowing() {
        assertMacro {
            functionWrapper(TestFunction.asyncThrowing)
        } expansion: {
            """
            @Test
            func asyncThrowing() async throws {}

            final class asyncThrowing_XCTest: XCTestCase {
                func testAsyncThrowing() async throws {
                    try await TestScaffold.run(testName: "asyncThrowing()", hostedBy: self)
                }
            }
            """
        }
    }


    func testNamedParam() {
        assertMacro {
            functionWrapper(TestFunction.namedParam)
        } expansion: {
            """
            @Test(arguments: [18, Int.max])
            func namedParam(age: Int) {
                #expect(age >= 18)
            }

            final class namedParam_XCTest: XCTestCase {
                func testNamedParam() async throws {
                    try await TestScaffold.run(testName: "namedParam(age:)", hostedBy: self)
                }
            }
            """
        }
    }

    func testUnnamedParam() {
        assertMacro {
            functionWrapper(TestFunction.unnamedParam)
        } expansion: {
            """
            @Test(arguments: [18, Int.max])
            func unnamedParam(_ age: Int) {
                #expect(age >= 18)
            }

            final class unnamedParam_XCTest: XCTestCase {
                func testUnnamedParam() async throws {
                    try await TestScaffold.run(testName: "unnamedParam(_:)", hostedBy: self)
                }
            }
            """
        }
    }

    func testMultiParam() {
        assertMacro {
            functionWrapper(TestFunction.multiParam)
        } expansion: {
            """
            @Test(arguments: [18, Int.max], ["Joe", "Lucy", "Alex"])
            func multiParam(age: Int, name: String) {
                #expect(age >= 18)
                #expect(name.count >= 3)
            }

            final class multiParam_XCTest: XCTestCase {
                func testMultiParam() async throws {
                    try await TestScaffold.run(testName: "multiParam(age:name:)", hostedBy: self)
                }
            }
            """
        }
    }
}
