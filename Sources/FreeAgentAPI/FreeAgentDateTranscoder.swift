import Foundation
import OpenAPIRuntime

/// A date transcoder that handles ISO 8601 dates with and without fractional seconds.
///
/// The FreeAgent API returns dates in both formats:
/// - With fractional seconds: `2020-05-01T00:00:00.000Z`
/// - Without fractional seconds: `2011-09-14T16:00:41Z`
public struct FreeAgentDateTranscoder: DateTranscoder {

    // MARK: Public

    public func encode(_ date: Date) throws -> String {
        date.formatted(withFractionalSeconds)
    }

    public func decode(_ dateString: String) throws -> Date {
        if let date = try? Date(dateString, strategy: withFractionalSeconds) {
            return date
        }
        if let date = try? Date(dateString, strategy: withoutFractionalSeconds) {
            return date
        }
        throw DecodingError.dataCorrupted(
            .init(
                codingPath: [],
                debugDescription: "Expected ISO 8601 date string, got: \(dateString)"
            )
        )
    }

    // MARK: Private

    private let withFractionalSeconds: Date.ISO8601FormatStyle = .iso8601.dateSeparator(.dash).timeSeparator(.colon)
        .timeZone(separator: .omitted).includingFractionalSeconds()

    private let withoutFractionalSeconds: Date.ISO8601FormatStyle = .iso8601.dateSeparator(.dash).timeSeparator(.colon)
        .timeZone(separator: .omitted)
}

extension DateTranscoder where Self == FreeAgentDateTranscoder {
    /// A date transcoder that handles ISO 8601 dates with and without fractional seconds.
    public static var freeAgent: Self { FreeAgentDateTranscoder() }
}
