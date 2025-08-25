import ArgumentParser
import FreeAgentAPI

extension CustomInvoiceView: ExpressibleByArgument {
    public static var allValueStrings: [String] {
        let staticCases = [
            "all",
            "recent_open_or_overdue",
            "open",
            "overdue",
            "open_or_overdue",
            "draft",
            "scheduled_to_email",
            "thank_you_emails",
            "reminder_emails"
        ]
        let dynamicExamples = ["last_N_months (where N is any number, e.g., last_1_months, last_24_months)"]
        return staticCases + dynamicExamples
    }
    
    public static var defaultCompletionKind: CompletionKind {
        .list(allValueStrings)
    }
}