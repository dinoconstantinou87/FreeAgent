import FreeAgentAPI

extension Components.Schemas.TaxReturnPayment.AmountDuePayload: CustomStringConvertible {
    public var description: String {
        switch self {
        case .case1(let amount):
            amount
        case .case2(let amount):
            amount.description
        }
    }
}
