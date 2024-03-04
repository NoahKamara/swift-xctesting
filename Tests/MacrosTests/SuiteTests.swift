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
            @XCTesting
            ╰─ ⚠️ Missing @Suite Attribute
            @Suite
            struct MyTests {
                @Test
            	func basic() {}
            }
            """
        } expansion: {
            """
            @Suite
            struct MyTests {
                @Test
            	func basic() {}
            }

            final class MyTests_XCTest: XCTestCase {
                func testBasic() async {
                    await Tests.run(suite: MyTests.self, test: "basic()", in: self)
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
            @XCTesting
            ╰─ ⚠️ Missing @Suite Attribute
            @Suite
            struct MyTests {
                @Test
            	func async() async {}
            }
            """
        } expansion: {
            """
            @Suite
            struct MyTests {
                @Test
            	func async() async {}
            }

            final class MyTests_XCTest: XCTestCase {
                func testAsync() async {
                    await Tests.run(suite: MyTests.self, test: "async()", in: self)
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
            @XCTesting
            ╰─ ⚠️ Missing @Suite Attribute
            @Suite
            struct MyTests {
                @Test
            	func throwing() throws {}
            }
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
                    await Tests.run(suite: MyTests.self, test: "throwing()", in: self)
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
            @XCTesting
            ╰─ ⚠️ Missing @Suite Attribute
            @Suite
            struct MyTests {
                @Test
            	func asyncThrowing() async throws {}
            }
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
                    await Tests.run(suite: MyTests.self, test: "asyncThrowing()", in: self)
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
            @XCTesting
            ╰─ ⚠️ Missing @Suite Attribute
            @Suite
            struct MyTests {
                @Test(arguments: [18, Int.max])
            	func namedParam(age: Int) {
            	    #expect(age >= 18)
            	}
            }
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
                func testNamedParam() async {
                    await Tests.run(suite: MyTests.self, test: "namedParam(age:)", in: self)
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
            @XCTesting
            ╰─ ⚠️ Missing @Suite Attribute
            @Suite
            struct MyTests {
                @Test(arguments: [18, Int.max])
            	func unnamedParam(_ age: Int) {
            	    #expect(age >= 18)
            	}
            }
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
                func testUnnamedParam() async {
                    await Tests.run(suite: MyTests.self, test: "unnamedParam(_:)", in: self)
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
            @XCTesting
            ╰─ ⚠️ Missing @Suite Attribute
            @Suite
            struct MyTests {
                @Test(arguments: [18, Int.max], ["Joe", "Lucy", "Alex"])
            	func multiParam(age: Int, name: String) {
            	    #expect(age >= 18)
            	    #expect(name.count >= 3)
            	}
            }
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
                func testMultiParam() async {
                    await Tests.run(suite: MyTests.self, test: "multiParam(age:name:)", in: self)
                }
            }
            """
        }
    }
}
