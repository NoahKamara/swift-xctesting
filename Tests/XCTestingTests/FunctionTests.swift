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
func standalone() {
    #expect(Bool(true))
}
