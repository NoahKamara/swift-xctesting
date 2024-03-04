import XCTesting

@XCTesting
@Test
func xselfHostedbasic() {
    #expect(Bool(true))
}

@XCTesting
@Test
func xselfHostedthrowing() throws {}

@XCTesting
@Test
func xselfHostedasync() async {}

@XCTesting
@Test
func xselfHostedasyncThrowing() async throws {}

@XCTesting
@Test(arguments: [18, Int.max])
func xselfHostednamedParam(age: Int) {
    #expect(age >= 18)
}

@XCTesting
@Test(arguments: [18, Int.max])
func xselfHostedunnamedParam(_ age: Int) {
    #expect(age >= 18)
}

@XCTesting
@Test(arguments: [18, Int.max], ["Joe", "Lucy", "Alex"])
func xselfHostedmultiParam(age: Int, name: String) {
    #expect(age >= 18)
    #expect(name.count >= 3)
}
