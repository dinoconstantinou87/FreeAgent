import Foundation

public enum CustomInvoiceView: Hashable, Sendable {
    case all
    case recentOpenOrOverdue
    case open
    case overdue
    case openOrOverdue
    case draft
    case scheduledToEmail
    case thankYouEmails
    case reminderEmails
    case lastMonths(Int)
}

extension CustomInvoiceView: RawRepresentable {
    public var rawValue: String {
        switch self {
        case .all:
            return "all"
        case .recentOpenOrOverdue:
            return "recent_open_or_overdue"
        case .open:
            return "open"
        case .overdue:
            return "overdue"
        case .openOrOverdue:
            return "open_or_overdue"
        case .draft:
            return "draft"
        case .scheduledToEmail:
            return "scheduled_to_email"
        case .thankYouEmails:
            return "thank_you_emails"
        case .reminderEmails:
            return "reminder_emails"
        case .lastMonths(let months):
            return "last_\(months)_months"
        }
    }
    
    public init?(rawValue: String) {
        switch rawValue {
        case "all":
            self = .all
        case "recent_open_or_overdue":
            self = .recentOpenOrOverdue
        case "open":
            self = .open
        case "overdue":
            self = .overdue
        case "open_or_overdue":
            self = .openOrOverdue
        case "draft":
            self = .draft
        case "scheduled_to_email":
            self = .scheduledToEmail
        case "thank_you_emails":
            self = .thankYouEmails
        case "reminder_emails":
            self = .reminderEmails
        default:
            if rawValue.hasPrefix("last_") && rawValue.hasSuffix("_months") {
                let numberPart = String(rawValue.dropFirst(5).dropLast(7))
                if let months = Int(numberPart), months > 0 {
                    self = .lastMonths(months)
                    return
                }
            }
            return nil
        }
    }
}

extension CustomInvoiceView: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        guard let value = CustomInvoiceView(rawValue: rawValue) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid invoice view value: \(rawValue)"
            )
        }
        
        self = value
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

