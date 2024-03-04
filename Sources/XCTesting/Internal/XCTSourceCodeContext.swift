//
//  File.swift
//  
//
//  Created by Noah Kamara on 04.03.24.
//

import XCTest

extension XCTSourceCodeContext {
    convenience init(_ sourceContext: SourceContext) {
        let addresses = sourceContext.backtrace?.addresses.map { $0 as NSNumber } ?? []
        let sourceLocation = sourceContext.sourceLocation.map { sourceLocation in
            XCTSourceCodeLocation(
                filePath: sourceLocation._filePath,
                lineNumber: sourceLocation.line
            )
        }
        self.init(callStackAddresses: addresses, location: sourceLocation)
    }
}
