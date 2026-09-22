import Foundation
import OAuthenticator

extension LoginStorage {
    static func backed(by storage: any AuthStorageInterface, environment: Environment) -> LoginStorage {
        LoginStorage(
            retrieveLogin: { try storage.get()?.login },
            storeLogin: { login in
                guard login.accessToken.valid else {
                    return
                }

                try storage.set(AuthCredential(login: login, environment: environment))
            }
        )
    }
}
