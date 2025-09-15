import Foundation

struct Definitions: Codable {
    let word: String
    let definitions: [Definition]
}

struct Definition: Codable {
    let definition: String
    let partOfSpeech: String
}

extension Definition: Identifiable {
    var id: String {
        definition
    }
}
