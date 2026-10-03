import FreeAgentAPI

extension PermissionLevel: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noAccess: "No Access"
        case .time: "Time"
        case .myMoney: "My Money"
        case .contactsAndProjects: "Contacts & Projects"
        case .invoicesEstimatesAndFiles: "Invoices, Estimates & Files"
        case .bills: "Bills"
        case .banking: "Banking"
        case .taxAccountingAndUsers: "Tax, Accounting & Users"
        case .full: "Full"
        }
    }
}
