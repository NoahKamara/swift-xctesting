
# XCTesting

A Swift Macro for generating XCTest compatible scaffolding around tests written for [swift-testing](https://github.com/apple/swift-testing)

This allows Test Suites & Cases Placeholders to be shown in
Even tough you shouldn't need more than the [Getting Started](#GettingStarted) Section there is an in progress Documentation hosted here: +[Documentation](https://noahkamara.github.io/swift-xctesting/documentation/xctesting/)
## Getting Started
- Swift Package Index
- Documentation

### Installing
First add XCTesting as a depency to your Swift Package or Xcode Project

```swift
// Dependency
.package(url: "https://github.com/NoahKamara/swift-xctesting.git", from: "0.1.0")

// Target Dependency
.product(name: "Testing", package: "swift-testing")
```

### Usage

Simply add the `@XCTesting` attribute to a Test or Suite and it will generate a `XCTestCase` with dummy tests

```swift
@XCTesting
@Suite
struct MyTests {
    @Test(arguments: [1,2,3])
    func example(arg: Int) {
        #expect(arg > 0
    }
}

// Expansion from XCTesting
class MyTests_XCTest: XCTestCase {
    func testExample() async throws {
        try await Tests.run(suite: MyTests.self, testName: "testExample(arg:)", hostedBy: self)
    }
}
```

If you apply `@XCTesting` to standalone test function it will generate a `XCTestCase` with only one dummy
> be warned: this might clutter xcodes test output
```swift
@Test(arguments: [1,2,3])
func standaloneExample(arg: Int) {
    #expect(arg > 0)
}

// Expansion from XCTesting
class standaloneExample_XCTest: XCTestCase {
    func testStandaloneExample() async throws {
        try await Tests.run(testName: "testExample(arg:)", hostedBy: self)
    }
}
```
## Contributing

Contributions are always welcome!

The Scope of this project should remain bridging swift-testing and XCTest for IDE support
## Roadmap

- [x] Scaffolding for Suites
- [x] Scaffolding for  Functions
- [x] Support Failures
- [x] Support Skip
- [ ] Add better documentation
- [ ] Investigate better supporting traits
- [ ] ...