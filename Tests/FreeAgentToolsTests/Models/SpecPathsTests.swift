import Foundation
import Testing

@testable import FreeAgentTools

struct SpecPathsTests {

    // MARK: Lifecycle

    init() throws {
        directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try write(Self.root, to: "openapi.yaml")
        try write(Self.bills, to: "paths/bills.yaml")
    }

    // MARK: Internal

    @Test("reads the operations of every path, through a reference or inline")
    func endpoints() throws {
        let endpoints = try SpecPaths.endpoints(rootURL: directory.appending(path: "openapi.yaml"))

        #expect(endpoints.map(\.description) == [
            "GET /v2/bills",
            "POST /v2/bills",
            "GET /v2/bills/{id}",
            "PUT /v2/bills/{id}",
            "DELETE /v2/bills/{id}",
            "GET /v2/company",
        ])
    }

    // MARK: Private

    private static let root = """
        openapi: 3.1.0
        paths:
          /v2/bills:
            $ref: 'paths/bills.yaml#/list'
          /v2/bills/{id}:
            $ref: 'paths/bills.yaml#/show'
          /v2/company:
            get:
              operationId: companyDetails
        """

    private static let bills = """
        list:
          get:
            operationId: listBills
          post:
            operationId: createBill
        show:
          get:
            operationId: showBill
          put:
            operationId: updateBill
          delete:
            operationId: deleteBill
          parameters:
          - $ref: '#/components/parameters/ID'
        """

    private let directory: URL

    private func write(_ contents: String, to path: String) throws {
        let url = directory.appending(path: path)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }
}
