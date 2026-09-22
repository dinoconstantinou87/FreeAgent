import Foundation
import FreeAgentAPI

extension AuthConfig {
    init(_ auth: Config.Auth, environment: Environment) {
        self.init(
            key: auth.key,
            secret: auth.secret,
            callbackUrl: auth.callbackUrl,
            environment: environment
        )
    }
}
