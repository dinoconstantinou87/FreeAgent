struct FieldSection<Record>: Sendable {
    init(_ title: String, fields: [Field<Record>]) {
        self.title = title
        self.fields = fields
    }

    let title: String
    let fields: [Field<Record>]

    func rows(_ record: Record) -> [(label: String, value: String)] {
        fields.compactMap { field in
            field.value(record).formatted().map { (field.label, $0) }
        }
    }
}
