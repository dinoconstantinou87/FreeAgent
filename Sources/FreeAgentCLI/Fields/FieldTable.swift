struct FieldTable<Record>: Sendable {
    init<Item>(
        _ title: String,
        items: @escaping @Sendable (Record) -> [Item]?,
        @FieldBuilder<Item> columns: () -> [Field<Item>]
    ) {
        let columns = columns()

        self.title = title
        headers = columns.map(\.label)
        rows = { record in
            (items(record) ?? []).map { item in columns.map { $0.cell(item) } }
        }
    }

    let title: String
    let headers: [String]
    let rows: @Sendable (Record) -> [[String]]
}
