//
//  File.swift
//  
//
//  Created by Noah Kamara on 04.03.24.
//

import Foundation

struct UncheckedSendable<T>: RawRepresentable, @unchecked Sendable {
    var rawValue: T

    init(rawValue: T) {
        self.rawValue = rawValue
    }
}


extension UncheckedSendable: CustomStringConvertible where T: CustomStringConvertible {
    var description: String {
        rawValue.description
    }
}

extension UncheckedSendable: CustomDebugStringConvertible where T: CustomDebugStringConvertible {
    var debugDescription: String {
        rawValue.debugDescription
    }
}
