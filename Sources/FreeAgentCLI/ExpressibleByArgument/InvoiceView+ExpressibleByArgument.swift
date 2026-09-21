import ArgumentParser
import FreeAgentAPI

extension CustomInvoiceView: ExpressibleByArgument {
    public static var allValueStrings: [String] {
        [
            CustomInvoiceView.all,
            .recentOpenOrOverdue,
            .open,
            .overdue,
            .openOrOverdue,
            .draft,
            .scheduledToEmail,
            .thankYouEmails,
            .reminderEmails,
        ].map(\.rawValue)
    }

    public static var defaultCompletionKind: CompletionKind {
        .list(allValueStrings)
    }
}
