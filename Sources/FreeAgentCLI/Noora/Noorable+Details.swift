import Noora

extension Noorable {

    // MARK: Internal

    func details<Record>(
        of record: Record,
        title: String,
        sections: [FieldSection<Record>],
        tables: [FieldTable<Record>]
    ) {
        let visibleSections = sections
            .map { (title: $0.title, rows: $0.rows(record)) }
            .filter { !$0.rows.isEmpty }
        let labels = visibleSections.flatMap { $0.rows.map(\.label) }
        let labelWidth = (labels.map(\.count).max() ?? 0) + ":  ".count

        var text = TerminalText.StringInterpolation(literalCapacity: 0, interpolationCount: 0)
        text.appendInterpolation(.primary(title))
        text.appendLiteral("\n")

        for section in visibleSections {
            text.appendLiteral("\n")
            text.appendInterpolation(.primary(section.title))
            text.appendLiteral("\n")

            for row in section.rows {
                text.appendLiteral("  \("\(row.label):".padded(to: labelWidth))\(row.value)\n")
            }
        }

        for table in tables {
            let rows = table.rows(record)

            guard !rows.isEmpty else {
                continue
            }

            text.appendLiteral("\n")
            text.appendInterpolation(.primary("\(table.title) (\(rows.count))"))
            text.appendLiteral("\n")
            text.appendLiteral(Self.aligned([table.headers] + rows))
        }

        passthrough(TerminalText(stringInterpolation: text))
    }

    // MARK: Private

    private static func aligned(_ lines: [[String]]) -> String {
        let widths = lines[0].indices.map { column in
            lines.map { $0[column].count }.max() ?? 0
        }

        return lines.map { cells in
            let padded = cells.enumerated().map { column, cell in
                column == cells.count - 1 ? cell : cell.padded(to: widths[column] + 2)
            }

            return "  \(padded.joined())\n"
        }.joined()
    }
}

extension String {
    fileprivate func padded(to width: Int) -> String {
        self + String(repeating: " ", count: max(0, width - count))
    }
}
