import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


@main
struct XCTestingPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        XCTestingMacro.self
    ]
}
