enum PermissionLevel: Int, CaseIterable {
    case noAccess
    case time
    case myMoney
    case contactsAndProjects
    case invoicesEstimatesAndFiles
    case bills
    case banking
    case taxAccountingAndUsers
    case full

    // MARK: Internal

    var name: String {
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

    static func name(for level: Int) -> String {
        PermissionLevel(rawValue: level)?.name ?? String(level)
    }
}
