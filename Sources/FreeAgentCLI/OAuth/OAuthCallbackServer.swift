import Foundation
import ServiceLifecycle
import Logging

struct OAuthCallbackServer: Sendable {
    private let port: Int
    
    init(port: Int) {
        self.port = port
    }
    
    func waitForOAuthCallback(expectedState: String) async throws -> String {
        let service = OAuthHTTPService(
            port: port,
            expectedState: expectedState
        )
        
        let serviceGroup = ServiceGroup(
            configuration: ServiceGroupConfiguration(
                services: [service],
                gracefulShutdownSignals: [.sigterm, .sigint],
                logger: Logger(label: "oauth-callback")
            )
        )
        
        return try await withThrowingTaskGroup(of: String.self) { group in
            group.addTask {
                try await serviceGroup.run()
                throw OAuthCallbackError.serverError("Service group ended unexpectedly")
            }
            
            group.addTask {
                try await service.waitForCallback()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

final class OAuthHTTPService: Service, Sendable {
    private let port: Int
    private let expectedState: String
    private let resultPromise: Promise<String>
    
    init(port: Int, expectedState: String) {
        self.port = port
        self.expectedState = expectedState
        self.resultPromise = Promise<String>()
    }
    
    func run() async throws {
        try await runSocketServer()
    }
    
    func waitForCallback() async throws -> String {
        return try await resultPromise.value
    }
    
    private func runSocketServer() async throws {
        let serverFd = socket(AF_INET, SOCK_STREAM, 0)
        guard serverFd >= 0 else {
            throw OAuthCallbackError.serverError("Failed to create socket")
        }
        defer { close(serverFd) }
        
        var reuseAddr: Int32 = 1
        setsockopt(serverFd, SOL_SOCKET, SO_REUSEADDR, &reuseAddr, socklen_t(MemoryLayout<Int32>.size))
        
        var serverAddr = sockaddr_in()
        serverAddr.sin_family = sa_family_t(AF_INET)
        serverAddr.sin_port = in_port_t(port).bigEndian
        serverAddr.sin_addr.s_addr = INADDR_ANY
        
        let bindResult = withUnsafePointer(to: &serverAddr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                bind(serverFd, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        
        guard bindResult == 0 else {
            throw OAuthCallbackError.serverError("Failed to bind to port \(port)")
        }
        
        guard listen(serverFd, 1) == 0 else {
            throw OAuthCallbackError.serverError("Failed to listen on socket")
        }
        
        let clientFd = accept(serverFd, nil, nil)
        guard clientFd >= 0 else {
            throw OAuthCallbackError.serverError("Failed to accept connection")
        }
        defer { close(clientFd) }
        
        var buffer = [UInt8](repeating: 0, count: 4096)
        let bytesRead = recv(clientFd, &buffer, buffer.count, 0)
        guard bytesRead > 0 else {
            throw OAuthCallbackError.invalidRequest
        }
        
        let request = String(bytes: Array(buffer[0..<bytesRead]), encoding: .utf8) ?? ""
        
        // Extract the request line (first line)
        let requestLine: String
        if let lineEnd = request.range(of: "\r\n")?.lowerBound {
            requestLine = String(request[..<lineEnd])
        } else if let lineEnd = request.range(of: "\n")?.lowerBound {
            requestLine = String(request[..<lineEnd])
        } else {
            requestLine = request
        }
        
        guard requestLine.starts(with: "GET ") else {
            throw OAuthCallbackError.invalidRequest
        }
        
        let pathComponents = requestLine.components(separatedBy: " ")
        guard pathComponents.count >= 2 else {
            throw OAuthCallbackError.invalidRequest
        }
        
        let path = pathComponents[1]
        guard let url = URL(string: "http://localhost\(path)"),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw OAuthCallbackError.invalidRequest
        }
        
        if let error = components.queryItems?.first(where: { $0.name == "error" })?.value {
            let description = components.queryItems?.first(where: { $0.name == "error_description" })?.value ?? ""
            sendErrorResponse(clientFd: clientFd, error: "\(error): \(description)")
            throw OAuthCallbackError.authenticationFailed(error: error, description: description)
        }
        
        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            sendErrorResponse(clientFd: clientFd, error: "No authorization code received")
            throw OAuthCallbackError.noCodeReceived
        }
        
        if let returnedState = components.queryItems?.first(where: { $0.name == "state" })?.value,
           returnedState != expectedState {
            sendErrorResponse(clientFd: clientFd, error: "State mismatch")
            throw OAuthCallbackError.stateMismatch
        }
        
        sendSuccessResponse(clientFd: clientFd)
        resultPromise.resolve(code)
    }
    
    private func sendSuccessResponse(clientFd: Int32) {
        let html = """
        <html>
        <head><title>Authentication Complete</title></head>
        <body style="font-family: system-ui; padding: 40px; text-align: center; background: #f5f5f5;">
            <h2 style="color: #28a745;">✅ Authentication Successful</h2>
            <p>You can close this window and return to the terminal.</p>
        </body>
        </html>
        """
        
        let response = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: \(html.utf8.count)\r\nConnection: close\r\n\r\n\(html)"
        let responseData = response.data(using: .utf8)!
        send(clientFd, responseData.withUnsafeBytes { $0.bindMemory(to: UInt8.self).baseAddress }, responseData.count, 0)
        shutdown(clientFd, SHUT_WR)
    }
    
    private func sendErrorResponse(clientFd: Int32, error: String) {
        let html = """
        <html>
        <head><title>Authentication Failed</title></head>
        <body style="font-family: system-ui; padding: 40px; text-align: center; background: #f5f5f5;">
            <h2 style="color: #dc3545;">❌ Authentication Failed</h2>
            <p>\(error)</p>
            <p>You can close this window and return to the terminal.</p>
        </body>
        </html>
        """
        
        let response = "HTTP/1.1 400 Bad Request\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: \(html.utf8.count)\r\nConnection: close\r\n\r\n\(html)"
        let responseData = response.data(using: .utf8)!
        send(clientFd, responseData.withUnsafeBytes { $0.bindMemory(to: UInt8.self).baseAddress }, responseData.count, 0)
        shutdown(clientFd, SHUT_WR)
    }
}

enum OAuthCallbackError: LocalizedError {
    case invalidRequest
    case noCodeReceived
    case stateMismatch
    case authenticationFailed(error: String, description: String)
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Invalid HTTP request received"
        case .noCodeReceived:
            return "No authorization code received in callback"
        case .stateMismatch:
            return "State parameter mismatch - possible CSRF attack"
        case .authenticationFailed(let error, let description):
            return "Authentication failed: \(error) - \(description)"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}

// Simple promise implementation for inter-task communication
private final class Promise<T>: @unchecked Sendable {
    private var result: Result<T, Error>?
    private var continuation: CheckedContinuation<T, Error>?
    private let lock = NSLock()
    
    var value: T {
        get async throws {
            try await withCheckedThrowingContinuation { continuation in
                lock.lock()
                defer { lock.unlock() }
                
                if let result = result {
                    continuation.resume(with: result)
                } else {
                    self.continuation = continuation
                }
            }
        }
    }
    
    func resolve(_ value: sending T) {
        lock.lock()
        defer { lock.unlock() }
        
        result = .success(value)
        continuation?.resume(returning: value)
        continuation = nil
    }
    
    func reject(_ error: Error) {
        lock.lock()
        defer { lock.unlock() }
        
        result = .failure(error)
        continuation?.resume(throwing: error)
        continuation = nil
    }
}