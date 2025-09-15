import Foundation

struct Word: Codable {
    let word: String
    let results: [ResultElement]
    let pronunciation: Pronunciation
}

struct Pronunciation: Codable {
    let all: String
}

extension Word {
    static let empty: Word = .init(word: "", results: [], pronunciation: .init(all: ""))
    static let sampleData: [Word] = [
        .init(
            word: "inevitable",
            results: [
                ResultElement(definition: "an unavoidable event",
                              partOfSpeech: "noun"),
                ResultElement(definition: "incapable of being avoided or prevented",
                              partOfSpeech: "adjective")
            ],
            pronunciation: .init(all: "ɪn'ɛvɪtəbəl")
        ),
        .init(
            word: "stunning",
            results: [
                ResultElement(definition: "strikingly beautiful or impressive",
                              partOfSpeech: "adjective")
            ],
            pronunciation: .init(all: "'stəniŋ")
        ),
        .init(
            word: "luminous",
            results: [
                ResultElement(definition: "emitting or reflecting light",
                              partOfSpeech: "adjective"),
                ResultElement(definition: "softly bright or radiant",
                              partOfSpeech: "adjective")
              ],
            pronunciation: .init(all: "'lumənəs")
        ),
    ]
}
