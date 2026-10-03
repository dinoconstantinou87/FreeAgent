import Foundation
import FreeAgentAPI

// MARK: - JournalEntryArgument

struct JournalEntryArgument: Sendable {

    // MARK: Lifecycle

    init(_ argument: String) throws(JournalEntryArgumentError) {
        var values = [Key: String]()

        for field in try Self.fields(in: argument) {
            guard let separator = field.firstIndex(of: "=") else {
                throw .missingValue(field)
            }

            let name = field[..<separator].trimmingCharacters(in: .whitespaces)
            let value = String(field[field.index(after: separator)...])

            guard let key = Key(rawValue: name) else {
                throw .unknownKey(name)
            }

            guard values[key] == nil else {
                throw .repeatedKey(key)
            }

            guard !value.isEmpty else {
                throw .emptyValue(key)
            }

            values[key] = value
        }

        guard let category = values[.category] else {
            throw .missingCategory
        }

        payload = try .init(
            category: ResourceID(category).value,
            debitValue: values[.debitValue].map(Self.debitValue),
            description: values[.description],
            user: values[.user].map { ResourceID($0).value },
            capitalAssetType: values[.capitalAssetType].map { ResourceID($0).value },
            stockItem: values[.stockItem].map { ResourceID($0).value },
            stockAlteringQuantity: values[.stockAlteringQuantity].map(Self.stockAlteringQuantity),
            contact: values[.contact].map { ResourceID($0).value }
        )
    }

    // MARK: Internal

    enum Key: String, CaseIterable, Sendable {
        case category
        case debitValue = "debit-value"
        case description
        case user
        case capitalAssetType = "capital-asset-type"
        case stockItem = "stock-item"
        case stockAlteringQuantity = "stock-altering-quantity"
        case contact
    }

    static let help = """
        An entry as comma-separated key=value fields, repeated for each entry: \
        \(Key.allCases.map(\.rawValue).joined(separator: ", ")). \
        A category is required, a negative debit value is a credit, and a value with a comma goes in double quotes
        """

    let payload: Components.Schemas.JournalEntryPayload

    // MARK: Private

    private static func fields(in argument: String) throws(JournalEntryArgumentError) -> [String] {
        var fields = [String]()
        var field = ""
        var isQuoted = false

        for character in argument {
            switch character {
            case "\"":
                isQuoted.toggle()

            case "," where !isQuoted:
                fields.append(field)
                field = ""

            default:
                field.append(character)
            }
        }

        guard !isQuoted else {
            throw .unclosedQuote
        }

        return fields + [field]
    }

    private static func debitValue(_ value: String) throws(JournalEntryArgumentError) -> Double {
        guard let number = Double(value), number.isFinite else {
            throw .notANumber(.debitValue, value)
        }

        return number
    }

    private static func stockAlteringQuantity(_ value: String) throws(JournalEntryArgumentError) -> Int {
        guard let number = Int(value) else {
            throw .notANumber(.stockAlteringQuantity, value)
        }

        return number
    }
}

// MARK: - JournalEntryArgumentError

enum JournalEntryArgumentError: LocalizedError, Equatable {
    case missingValue(String)
    case unknownKey(String)
    case repeatedKey(JournalEntryArgument.Key)
    case emptyValue(JournalEntryArgument.Key)
    case notANumber(JournalEntryArgument.Key, String)
    case missingCategory
    case unclosedQuote

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .missingValue(let field):
            "'\(field)' is not a key=value field"
        case .unknownKey(let key):
            "'\(key)' is not a key - use \(JournalEntryArgument.Key.allCases.map(\.rawValue).joined(separator: ", "))"
        case .repeatedKey(let key):
            "\(key.rawValue) is given more than once"
        case .emptyValue(let key):
            "\(key.rawValue) needs a value"
        case .notANumber(let key, let value):
            "\(key.rawValue) must be a number, not '\(value)'"
        case .missingCategory:
            "every entry needs a category"
        case .unclosedQuote:
            "a double quote is not closed"
        }
    }
}
