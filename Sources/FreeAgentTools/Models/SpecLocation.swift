import Foundation

struct SpecLocation: Hashable {
    init(file: URL, pointer: String? = nil) {
        self.file = URL(fileURLWithPath: file.absoluteURL.standardizedFileURL.path)
        self.pointer = pointer
    }

    let file: URL
    let pointer: String?
}
