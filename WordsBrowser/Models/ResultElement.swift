import Foundation

struct ResultElement: Codable {
    let definition: String
    let partOfSpeech: String
}

extension ResultElement: Identifiable {
    var id: String {
        definition
    }
}
