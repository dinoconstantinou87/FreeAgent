public enum PermissionLevel: Int, Codable, Hashable, Sendable, CaseIterable {
    case noAccess = 0
    case time = 1
    case myMoney = 2
    case contactsAndProjects = 3
    case invoicesEstimatesAndFiles = 4
    case bills = 5
    case banking = 6
    case taxAccountingAndUsers = 7
    case full = 8
}
