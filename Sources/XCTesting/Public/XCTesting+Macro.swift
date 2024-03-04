import XCTestingMacros


/// Mark a @Test or @Suite for compatibility with XCTest
@attached(peer, names: suffixed(_XCTest))
public macro XCTesting() = #externalMacro(module: "XCTestingMacros", type: "XCTestingMacro")




@_spi(ExperimentalEventHandling) @_spi(ExperimentalTestRunning) @_spi(ExperimentalEventRecording) @_spi(ForToolsIntegrationOnly) import Testing


extension Event.Kind: CustomStringConvertible {
    var rawValue: String {
        switch self {
            case .runStarted:
                "runStarted"
            case .iterationStarted:
                "iterationStarted"
            case .planStepStarted:
                "planStepStarted"
            case .testStarted:
                "testStarted"
            case .testCaseStarted:
                "testCaseStarted"
            case .testCaseEnded:
                "testCaseEnded"
            case .expectationChecked:
                "expectationChecked"
            case .issueRecorded:
                "issueRecorded"
            case .testEnded:
                "testEnded"
            case .testSkipped:
                "testSkipped"
            case .planStepEnded:
                "planStepEnded"
            case .iterationEnded:
                "iterationEnded"
            case .runEnded:
                "runEnded"
        }
    }

    public var description: String {
        let detail = switch self {
        case .iterationStarted(let index), .iterationEnded(let index):
            "\(index)"

        case .planStepStarted(let step), .planStepEnded(let step):
            "\(step.test.id)"

        case .expectationChecked(let exp):
            "(\(exp.isPassing ? "✓" : "✕")) \(exp.evaluatedExpression)"

        case .issueRecorded(let issue):
            issue.description

        case .testSkipped(let skipInfo):
            skipInfo.localizedDescription

        default:
            String?.none
        }
        
        return if let detail {
            "[\(rawValue)] \(detail)"
        } else {
            "[\(rawValue)]"
        }
    }
}
