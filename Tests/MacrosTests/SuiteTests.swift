import MacroTesting
import XCTest
@testable import XCTestingMacros

final class SuiteTests: XCTestCase {
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
            suiteWrapper(TestFunction.basic)
        } diagnostics: {
            """

            """
        } expansion: {
            """
            @Suite
            struct MyTests {
                @Test
            	func basic() {}
            }

            final class MyTests_XCTest: XCTestCase {
                func testBasic() async throws {
                    try await TestScaffold.run(suite: MyTests.self, testName: "basic()", hostedBy: self)
                }
            }
            """
        }
    }

    func testAsync() {
        assertMacro {
            suiteWrapper(TestFunction.async)
        } diagnostics: {
            """

            """
        } expansion: {
            """
            @Suite
            struct MyTests {
                @Test
            	func async() async {}
            }

            final class MyTests_XCTest: XCTestCase {
                func testAsync() async throws {
                    try await TestScaffold.run(suite: MyTests.self, testName: "async()", hostedBy: self)
                }
            }
            """
        }
    }

    func testThrowing() {
        assertMacro {
            suiteWrapper(TestFunction.throwing)
        } diagnostics: {
            """

            """
        } expansion: {
            """
            @Suite
            struct MyTests {
                @Test
            	func throwing() throws {}
            }

            final class MyTests_XCTest: XCTestCase {
                func testThrowing() async throws {
                    try await TestScaffold.run(suite: MyTests.self, testName: "throwing()", hostedBy: self)
                }
            }
            """
        }
    }

    func testAsyncThrowing() {
        assertMacro {
            suiteWrapper(TestFunction.asyncThrowing)
        } diagnostics: {
            """

            """
        } expansion: {
            """
            @Suite
            struct MyTests {
                @Test
            	func asyncThrowing() async throws {}
            }

            final class MyTests_XCTest: XCTestCase {
                func testAsyncThrowing() async throws {
                    try await TestScaffold.run(suite: MyTests.self, testName: "asyncThrowing()", hostedBy: self)
                }
            }
            """
        }
    }


    func testNamedParam() {
        assertMacro {
            suiteWrapper(TestFunction.namedParam)
        } diagnostics: {
            """

            """
        } expansion: {
            """
            @Suite
            struct MyTests {
                @Test(arguments: [18, Int.max])
            	func namedParam(age: Int) {
            	    #expect(age >= 18)
            	}
            }

            final class MyTests_XCTest: XCTestCase {
                func testNamedParam() async throws {
                    try await TestScaffold.run(suite: MyTests.self, testName: "namedParam(age:)", hostedBy: self)
                }
            }
            """
        }
    }

    func testUnnamedParam() {
        assertMacro {
            suiteWrapper(TestFunction.unnamedParam)
        }diagnostics: {
            """

            """
        } expansion: {
            """
            @Suite
            struct MyTests {
                @Test(arguments: [18, Int.max])
            	func unnamedParam(_ age: Int) {
            	    #expect(age >= 18)
            	}
            }

            final class MyTests_XCTest: XCTestCase {
                func testUnnamedParam() async throws {
                    try await TestScaffold.run(suite: MyTests.self, testName: "unnamedParam(_:)", hostedBy: self)
                }
            }
            """
        }
    }

    func testMultiParam() {
        assertMacro {
            suiteWrapper(TestFunction.multiParam)
        } diagnostics: {
            """

            """
        } expansion: {
            """
            @Suite
            struct MyTests {
                @Test(arguments: [18, Int.max], ["Joe", "Lucy", "Alex"])
            	func multiParam(age: Int, name: String) {
            	    #expect(age >= 18)
            	    #expect(name.count >= 3)
            	}
            }

            final class MyTests_XCTest: XCTestCase {
                func testMultiParam() async throws {
                    try await TestScaffold.run(suite: MyTests.self, testName: "multiParam(age:name:)", hostedBy: self)
                }
            }
            """
        }
    }
}
