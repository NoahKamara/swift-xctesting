import XCTesting

@XCTesting
@Test
func xselfHostedbasic() {
    #expect(Bool(true))
}

@XCTesting
@Test
func xselfHostedThrowing() throws {}

@XCTesting
@Test(.disabled("Disabled"))
func xselfHostedDisabled() async {}


@XCTesting
@Test
func xselfHostedAsync() async {}

@XCTesting
@Test
func xselfHostedAsyncThrowing() async throws {}

@XCTesting
@Test(arguments: [18, Int.max])
func xselfHostednamedParam(age: Int) {
    #expect(age >= 18)
}

@XCTesting
@Test(arguments: [18, Int.max])
func xselfHostedUnnamedParam(_ age: Int) {
    #expect(age >= 18)
}

@XCTesting
@Test(arguments: [18, Int.max], ["Joe", "Lucy", "Alex"])
func xselfHostedMultiParam(age: Int, name: String) {
    #expect(age >= 18)
    #expect(name.count >= 3)
}
