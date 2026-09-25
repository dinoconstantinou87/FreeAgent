struct Field<Item>: Sendable {
    init(_ label: String, value: @escaping @Sendable (Item) -> FieldValue) {
        self.label = label
        self.value = value
    }

    let label: String
    let value: @Sendable (Item) -> FieldValue

    func cell(_ item: Item) -> String {
        value(item).formatted() ?? "-"
    }
}
