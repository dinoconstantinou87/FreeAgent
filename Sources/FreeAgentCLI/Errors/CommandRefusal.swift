enum CommandRefusal: Error, Equatable {
    case notInteractive
    case declined
    case fileExists(path: String)
}
