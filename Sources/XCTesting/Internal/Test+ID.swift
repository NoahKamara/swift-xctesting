//
//  File.swift
//  
//
//  Created by Noah Kamara on 04.03.24.
//

//@_spi(ExperimentalEventHandling) @_spi(ExperimentalTestRunning) @_spi(ExperimentalEventRecording) @_spi(ForToolsIntegrationOnly) import Testing
@_spi(ExperimentalTestRunning) import Testing


extension Test.ID {
    init(suite: Any.Type, testName: String) {
        var components = _typeName(suite, qualified: true)
            .split(separator: ".")
            .map(String.init)

        // If a type is extended in another module and then referenced by name, its
        // name according to the _typeName(_:qualified:) SPI will be prefixed with
        // "(extension in MODULE_NAME):". For our purposes, we never want to preserve
        // that prefix.
        if let firstComponent = components.first, firstComponent.starts(with: "(extension in ") {
            components[0] = String(firstComponent.split(separator: ":", maxSplits: 1).last!)
        }

        let moduleName = components.first ?? ""
        let nameComponents: [String] = if components.count > 0 {
            Array(components.dropFirst())
        } else {
            []
        }

        self.init(
            moduleName: moduleName,
            nameComponents: nameComponents + [testName],
            sourceLocation: nil
        )
    }
}

extension Test.ID {
    init(fileID: String, testName: String) {
        let firstSlash = fileID.firstIndex(of: "/")!
        let moduleName = String(fileID[..<firstSlash])

        self.init(
            moduleName: moduleName,
            nameComponents: [testName],
            sourceLocation: nil
        )
    }
}
