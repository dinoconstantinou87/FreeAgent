import Foundation

public enum Environment: String, Codable, Sendable {
    case production
    case sandbox
    
    public var baseURL: URL {
        switch self {
        case .production:
            return try! Servers.Server1.url()
        case .sandbox:
            return try! Servers.Server2.url()
        }
    }

    func url(_ path: String) -> URL {
        baseURL.appending(path: path)
    }
}
