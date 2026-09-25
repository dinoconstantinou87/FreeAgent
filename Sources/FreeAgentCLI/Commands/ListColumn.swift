struct ListColumn<Item>: Sendable {
    init(_ header: String, cell: @escaping @Sendable (Item) -> ListCell) {
        self.header = header
        self.cell = cell
    }

    let header: String
    let cell: @Sendable (Item) -> ListCell
}
