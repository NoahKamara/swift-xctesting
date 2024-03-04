//
//  File.swift
//  
//
//  Created by Noah Kamara on 04.03.24.
//

import XCTest

extension XCTIssue {
    init(_ issue: Issue) {
        var error = issue.error

        let issueType: XCTIssue.IssueType
        switch issue.kind {
            case .expectationFailed, .confirmationMiscounted:
                issueType = .assertionFailure
            case .errorCaught:
                issueType = .thrownError
            case let .timeLimitExceeded(timeLimitComponents: timeLimitComponents):
                issueType = .thrownError
                if error == nil {
                    error = TimeoutError(timeLimit: timeLimitComponents)
                }
            case .unconditional:
                issueType = .assertionFailure
            case .knownIssueNotRecorded:
                issueType = .unmatchedExpectedFailure
            case .apiMisused, .system:
                issueType = .system
        }

        self.init(
            type: issueType,
            compactDescription: String(describing: issue),
            detailedDescription: nil,
            sourceCodeContext: XCTSourceCodeContext(issue.sourceContext),
            associatedError: error,
            attachments: []
        )
    }
}



struct TimeoutError: Error, CustomStringConvertible {
    typealias TimeValue = (seconds: Int64, attoseconds: Int64)

    /// The time limit exceeded by the test that timed out.
    var timeLimit: TimeValue

    var seconds: Int64 { timeLimit.seconds }
    var attoseconds: Int64 { timeLimit.attoseconds }

    init(timeLimit: TimeValue) {
        self.timeLimit = timeLimit
    }

    var description: String {
        let (secondsFromAttoseconds, attosecondsRemaining) = attoseconds.quotientAndRemainder(dividingBy: 1_000_000_000_000_000_000)
        let seconds = seconds + secondsFromAttoseconds
        var milliseconds = attosecondsRemaining / 1_000_000_000_000_000
        if seconds == 0 && milliseconds == 0 && attosecondsRemaining > 0 {
            milliseconds = 1
        }

        return withUnsafeTemporaryAllocation(of: CChar.self, capacity: 512) { buffer in
            withVaList([CLongLong(seconds), CInt(milliseconds)]) { args in
                _ = vsnprintf(buffer.baseAddress!, buffer.count, "%lld.%03d seconds", args)
            }
            return String(cString: buffer.baseAddress!)
        }
    }
}
