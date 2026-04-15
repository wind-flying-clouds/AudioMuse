import Foundation

struct AMLyricLineContent: Equatable, Identifiable {
    let id: String
    let text: String
    let time: TimeInterval?

    init(
        id: String,
        text: String,
        time: TimeInterval? = nil,
    ) {
        self.id = id
        self.text = text
        self.time = time
    }

    var isTimed: Bool {
        time != nil
    }
}
