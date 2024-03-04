//
//  File.swift
//  
//
//  Created by Noah Kamara on 04.03.24.
//

import SwiftSyntax
import SwiftSyntaxMacros

extension XCTestingMacro {
    static func expandSuite(
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> ClassDeclSyntax {
        let suite: any SuiteDeclaration = switch declaration.kind {
        case .classDecl: declaration.as(ClassDeclSyntax.self)!
        case .structDecl: declaration.as(StructDeclSyntax.self)!
        default:
            throw DiagnosticBuilder(for: declaration)
                .message("Unsupported Suite \(declaration.kind)")
                .error()

        }

        guard !suite.isSuite else {
            DiagnosticBuilder(for: declaration)
                .message("Missing @Suite Attribute")
                .severity(.warning)
                .emit(context)
            
            return createTestHost(
                name: suite.name,
                tests: [],
                in: context
            )
        }

        let tests = suite
            .memberBlock
            .members
            .map(\.decl)
            .compactMap { item in
                guard let function = item.as(FunctionDeclSyntax.self) else {
                    DiagnosticBuilder(for: item)
                        .message("ignored: not a function")
                        .severity(.note)
                        .emit(context)

                    return FunctionDeclSyntax?.none
                }

                guard function.attributes.contains(where: { $0.trimmedDescription.starts(with: "@Test") }) else {
                    DiagnosticBuilder(for: item)
                        .message("ignored: function does not have @Test attribute")
                        .severity(.note)
                        .emit(context)

                    return FunctionDeclSyntax?.none
                }
                return function
            }
            .compactMap({ expandTest(suite: suite, declaration: $0, in: context) })

        let host = createTestHost(
            name: suite.name,
            tests: tests,
            in: context
        )

        return host
    }
}


/// Shared interface for ClassDeclSyntax & StructDeclSyntax
protocol SuiteDeclaration {
    var attributes: AttributeListSyntax { get }
    var memberBlock: MemberBlockSyntax { get }
    var name: TokenSyntax { get }
}

extension SuiteDeclaration {
    /// Whether this declaration has an @Suite Attribute
    var isSuite: Bool {
        attributes.contains(where: { $0.trimmedDescription.starts(with: "@Suite") })
    }
}

extension ClassDeclSyntax: SuiteDeclaration {}
extension StructDeclSyntax: SuiteDeclaration {}
