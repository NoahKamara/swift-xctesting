import XCTesting

@XCTesting
@Suite
struct SuiteTests {
    @Test(.disabled("Not Implemented"))
    func disabled() {
        #expect(Bool(false))
    }

    @Test
    func withKnownIssues() {
        withKnownIssue {
            #expect(Bool(false))
        }
    }

    @Test
    func basic() {
        #expect(Bool(true))
    }

    @Test
    func throwing() throws {}

    @Test
    func async() async {}

    @Test
    func asyncThrowing() async throws {}

    @Test(arguments: [18, Int.max])
    func namedParam(age: Int) {
        #expect(age >= 18)
    }

    @Test(arguments: [18, Int.max])
    func unnamedParam(_ age: Int) {
        #expect(age >= 18)
    }

    @Test(arguments: [18, Int.max], ["Joe", "Lucy", "Alex"])
    func multiParam(age: Int, name: String) {
        #expect(age >= 18)
        #expect(name.count >= 3)
    }
}
