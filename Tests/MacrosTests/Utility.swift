

enum TestFunction {
    static var basic: String {
        """
        @Test
        func basic() {}
        """
    }

    static var throwing: String {
        """
        @Test
        func throwing() throws {}
        """
    }

    static var async: String {
        """
        @Test
        func async() async {}
        """
    }

    static var asyncThrowing: String {
        """
        @Test
        func asyncThrowing() async throws {}
        """
    }

    static var namedParam: String {
        """
        @Test(arguments: [18, Int.max])
        func namedParam(age: Int) {
            #expect(age >= 18)
        }
        """
    }

    static var unnamedParam: String {
        """
        @Test(arguments: [18, Int.max])
        func unnamedParam(_ age: Int) {
            #expect(age >= 18)
        }
        """
    }

    static var multiParam: String {
        """
        @Test(arguments: [18, Int.max], ["Joe", "Lucy", "Alex"])
        func multiParam(age: Int, name: String) {
            #expect(age >= 18)
            #expect(name.count >= 3)
        }
        """
    }
}

func suiteWrapper(_ functions: String...) -> String {
"""
@XCTesting
@Suite
struct MyTests {
    \(functions.map({ $0.split(separator: "\n").joined(separator: "\n\t") }).joined(separator: "\n"))
}
"""
}


func functionWrapper(_ function: String) -> String {
"""
@XCTesting
\(function)
"""
}
