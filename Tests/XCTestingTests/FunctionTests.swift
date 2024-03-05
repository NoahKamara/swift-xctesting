import XCTesting
import Foundation


@XCTesting
@Test
func AATest() {
    withKnownIssue {
        #expect(Bool(false))
    }
    print("HI")
    #expect(Bool(false))
    print("ENVIRONMENT")
    ProcessInfo.processInfo.environment.forEach { (key, value) in
        print("  "+key, value)
    }

    print("\n\n")
    ProcessInfo.processInfo.arguments.forEach { value in
        print("  "+value)
    }

    print(ProcessInfo.processInfo.processIdentifier, ProcessInfo.processInfo.globallyUniqueString)
}


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
