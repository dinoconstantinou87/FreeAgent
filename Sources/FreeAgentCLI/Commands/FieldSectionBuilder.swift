@resultBuilder
enum FieldSectionBuilder<Record> {
    static func buildExpression(_ section: FieldSection<Record>) -> FieldSection<Record> {
        section
    }

    static func buildBlock(_ sections: FieldSection<Record>...) -> [FieldSection<Record>] {
        sections
    }
}
