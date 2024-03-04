import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension String {
    func titlecase() -> String {
        if let first = first?.uppercased() {
            first+dropFirst()
        } else { "" }
    }
}


public struct XCTestingMacro: PeerMacro {
    /// Expands a swift-testing function into a XCTest method
    /// - Parameters:
    ///   - suite: Suite Declaration if the test was contained in a suite
    ///   - declaration: test function
    ///   - context:
    /// - Returns: XCTest method
    static func expandTest(
        suite: (any SuiteDeclaration)?,
        declaration: FunctionDeclSyntax,
        in context: some MacroExpansionContext
    ) -> FunctionDeclSyntax? {
        // Check @Test
        guard declaration.attributes.contains(where: { $0.trimmedDescription.starts(with: "@Test") }) else {
            DiagnosticBuilder(for: declaration)
                .message("ignored: function does not have @Test attribute")
                .severity(.note)
                .emit(context)
            return nil
        }

        let funcName: TokenSyntax = TokenSyntax(stringLiteral: "test"+declaration.name.trimmedDescription.titlecase())

        var decl = FunctionDeclSyntax(name: funcName, signature: .init(parameterClause: .init(parameters: [])))

        // Effects
        var effects = (declaration.signature.effectSpecifiers ?? .init())

        // Add async if necessary
        if effects.asyncSpecifier == nil {
            effects.asyncSpecifier = "async"
        }

        decl.signature.effectSpecifiers = effects

        // Create function ID
        let parameterID = declaration
            .signature
            .parameterClause
            .parameters
            .map({ $0.firstName.text+":" })
            .joined(separator: "")

        let testFuncID = "\(declaration.name)(\(parameterID))"

        if let suite {
            decl.body = .init(statements: [
                "await Tests.run(suite: \(suite.name.trimmed).self, test: \"\(raw: testFuncID)\", in: self)"
            ])
        } else {
            decl.body = .init(statements: [
                "await Tests.run(suite: nil, test: \"\(raw: testFuncID)\", in: self)"
            ])
        }

        return decl
    }
    
    /// Create XCTestCase host
    /// - Parameters:
    ///   - name: name that will be suffixed with `_XCTest`
    ///   - tests: XCTestCase methods
    ///   - context:
    /// - Returns: A XCTestCase hosting the provided tests
    public static func createTestHost(
        name: TokenSyntax,
        tests: [FunctionDeclSyntax],
        in context: some MacroExpansionContext
    ) -> ClassDeclSyntax {
        var host = ClassDeclSyntax(
            modifiers: [DeclModifierSyntax(name: "final")],
            classKeyword: .keyword(.class),
            name: "\(name.trimmed)_XCTest",
            inheritanceClause: .init(inheritedTypes: [.init(type: IdentifierTypeSyntax(name: "XCTestCase"))]),
            memberBlock: .init(members: [])
        )
        host.memberBlock.members.append(contentsOf: tests.map({ MemberBlockItemSyntax(decl: $0) }) )
        return host
    }


    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        do {
            let testHost = switch declaration.kind {
            case .structDecl, .classDecl:
                try expandSuite(
                    providingPeersOf: declaration,
                    in: context
                )

            case .functionDecl:
                try expandFunction(
                    providingPeersOf: declaration,
                    in: context
                )

            default:
                throw DiagnosticBuilder(for: declaration)
                    .message("Can only be applied to @Suite class/struct and `@Test func`")
                    .error()
            }

            return [DeclSyntax(testHost)]
        } catch let error as DiagnosticError {
            context.diagnose(error.diagnostic)
            return []
        }
    }
}

@main
struct swift_xctestingPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        XCTestingMacro.self
    ]
}
