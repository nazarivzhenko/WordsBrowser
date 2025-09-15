import SwiftUI

final class WordsData {
    let wordsString: [String] = ["inevitable", "stunning", "luminous"]
    let wordsAPI = WordsAPI()
    
    func fetchWords() async throws -> [Word] {
        try await withThrowingTaskGroup(of: Word.self) { group in
            wordsString.forEach { wordString in
                group.addTask {
                    try await self.wordsAPI.fetch(wordString)
                }
            }
            
            var words: [Word] = []
            for try await word in group {
                words.append(word)
            }
            
            return words
        }
    }
    
    func fetchWord(_ word: String) async throws -> Word {
        try await self.wordsAPI.fetch(word)
    }
    
    func fetchSynonyms(_ word: String) async throws -> Synonyms {
        try await self.wordsAPI.fetch(word, path: "synonyms")
    }
    
    func fetchExamples(_ word: String) async throws -> Examples {
        try await self.wordsAPI.fetch(word, path: "examples")
    }
}
