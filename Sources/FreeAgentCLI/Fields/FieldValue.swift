import Foundation

enum FieldValue: Sendable {
    case id(url: String?)
    case text(String?)
    case date(String?)
    case timestamp(Date?)
    case currency(String?, code: String?)
    case percent(String?)
    case number(Int?)
    case bytes(Int?)
    case flag(Bool?)
    case status(String?)

    // MARK: Internal

    func formatted(locale: Locale = .current, timeZone: TimeZone = .current) -> String? {
        let text =
            switch self {
            case .id(let url):
                url.map { URL(string: $0)?.lastPathComponent ?? $0 }
            case .text(let text), .date(let text), .status(let text):
                text
            case .timestamp(let date):
                date?.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, locale: locale, timeZone: timeZone))
            case .currency(let amount, let code):
                amount.map { Self.currency($0, code: code, locale: locale) }
            case .percent(let rate):
                rate.map { Self.percent($0, locale: locale) }
            case .number(let number):
                number?.formatted(.number.locale(locale))
            case .bytes(let bytes):
                bytes.map { Int64($0).formatted(.byteCount(style: .file).locale(locale)) }
            case .flag(let flag):
                flag.map { $0 ? "Yes" : "No" }
            }

        return text?.isEmpty == false ? text : nil
    }

    // MARK: Private

    private static func decimal(_ string: String) -> Decimal? {
        Decimal(string: string, locale: Locale(identifier: "en_US_POSIX"))
    }

    private static func currency(_ amount: String, code: String?, locale: Locale) -> String {
        guard let value = decimal(amount) else {
            return amount
        }

        guard let code else {
            return value.formatted(.number.precision(.fractionLength(2)).locale(locale))
        }

        return value.formatted(.currency(code: code).locale(locale))
    }

    private static func percent(_ rate: String, locale: Locale) -> String {
        guard let value = decimal(rate) else {
            return rate
        }

        return (value / 100).formatted(.percent.locale(locale))
    }
}
