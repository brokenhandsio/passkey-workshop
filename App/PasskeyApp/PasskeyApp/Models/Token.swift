import Foundation

struct Token: Codable {
    var id: UUID?
    var value: String

    init(value: String) {
        self.value = value
    }
}
