import Foundation
import Mockable

// MARK: - FileManagerInterface

@Mockable
public protocol FileManagerInterface: Sendable {
    func contents(atPath path: String) -> Data?
    func fileExists(atPath path: String) -> Bool
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws
    func write(_ data: Data, to url: URL) throws
    func removeItem(at url: URL) throws
}

// MARK: - FileManager + FileManagerInterface

extension FileManager: FileManagerInterface {
    public func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool) throws {
        try createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: nil)
    }

    public func write(_ data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }
}
