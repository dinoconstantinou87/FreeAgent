@resultBuilder
enum FieldBuilder<Item> {
    static func buildExpression(_ field: Field<Item>) -> [Field<Item>] {
        [field]
    }

    static func buildExpression(_ fields: [Field<Item>]) -> [Field<Item>] {
        fields
    }

    static func buildBlock(_ components: [Field<Item>]...) -> [Field<Item>] {
        components.flatMap(\.self)
    }
}
