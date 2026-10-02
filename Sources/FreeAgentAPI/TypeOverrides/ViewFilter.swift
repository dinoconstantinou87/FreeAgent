import Foundation

// MARK: - ViewFilter

public enum ViewFilter<Name: RawRepresentable<String> & CaseIterable & Hashable & Sendable>: Hashable, Sendable {
    case named(Name)
    case lastMonths(Int)
}

public typealias InvoiceViewFilter = ViewFilter<Components.Schemas.InvoiceViewName>

public typealias CreditNoteViewFilter = ViewFilter<Components.Schemas.CreditNoteViewName>

// MARK: - ViewFilter + RawRepresentable

extension ViewFilter: RawRepresentable {

    // MARK: Lifecycle

    public init?(rawValue: String) {
        if let name = Name(rawValue: rawValue) {
            self = .named(name)
            return
        }

        guard
            rawValue.hasPrefix("last_"),
            rawValue.hasSuffix("_months"),
            let months = Int(rawValue.dropFirst(5).dropLast(7)),
            months > 0
        else {
            return nil
        }

        self = .lastMonths(months)
    }

    // MARK: Public

    public var rawValue: String {
        switch self {
        case .named(let name):
            name.rawValue
        case .lastMonths(let months):
            "last_\(months)_months"
        }
    }

}

// MARK: - ViewFilter + Codable

extension ViewFilter: Codable {

    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        guard let value = ViewFilter(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid view value: \(rawValue)"
            )
        }

        self = value
    }

    // MARK: Public

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
