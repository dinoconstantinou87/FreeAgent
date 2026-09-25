import Foundation
import Noora

extension Terminal {
    static func canPrompt() -> Bool {
        isInteractive() && isatty(STDOUT_FILENO) != 0
    }
}
