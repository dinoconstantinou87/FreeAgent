import Foundation

enum ListCell: Sendable {
    case id(url: String)
    case text(String?)
    case date(String?)
    case currency(String?, code: String?)
    case status(String?)

    // MARK: Internal

    func formatted(locale: Locale = .current) -> String {
        switch self {
        case .id(let url):
            URL(string: url)?.lastPathComponent ?? url
        case .text(let text), .date(let text), .status(let text):
            text ?? "-"
        case .currency(let amount, let code):
            Self.currency(amount, code: code, locale: locale)
        }
    }

    // MARK: Private

    private static func currency(_ amount: String?, code: String?, locale: Locale) -> String {
        guard let amount else {
            return "-"
        }

        guard let value = Decimal(string: amount, locale: Locale(identifier: "en_US_POSIX")) else {
            return amount
        }

        guard let code else {
            return value.formatted(.number.precision(.fractionLength(2)).locale(locale))
        }

        return value.formatted(.currency(code: code).locale(locale))
    }
}
