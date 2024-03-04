//
//  File.swift
//  
//
//  Created by Noah Kamara on 04.03.24.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

extension XCTestingMacro {
    static func expandFunction(
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> ClassDeclSyntax {
        guard let function = declaration.as(FunctionDeclSyntax.self) else {
            throw DiagnosticBuilder(for: declaration)
                .message("Unsupported Test \(declaration.kind)")
                .error()
        }

        guard let test = expandTest(suite: nil, declaration: function, in: context) else {
            throw DiagnosticBuilder(for: declaration)
                .message("Fatal Error")
                .error()
        }

        let host = createTestHost(
            name: function.name.trimmed,
            tests: [test],
            in: context
        )


        guard function.attributes.contains(where: { $0.trimmedDescription.starts(with: "@Test") }) else {
            DiagnosticBuilder(for: function)
                .message("test will not run\n\tfunction does not have @Test attribute")
                .severity(.warning)
                .emit(context)
            return host
        }



        return host
    }


}
