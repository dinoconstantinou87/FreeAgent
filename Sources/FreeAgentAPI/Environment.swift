import Foundation

public enum Environment: String, Codable, Sendable {
    case production
    case sandbox

    public var baseURL: URL {
        switch self {
        case .production:
            try! Servers.Server1.url()
        case .sandbox:
            try! Servers.Server2.url()
        }
    }

    func url(_ path: String) -> URL {
        baseURL.appending(path: path)
    }
}
