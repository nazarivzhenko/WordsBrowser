import Foundation
import OSLog

struct WordsAPI {
    enum APIError: Error {
        case invalidURL
        case invalidServerResponse
        case decodingFailed
        case noData
    }
    
    let urlBase = "https://wordsapiv1.p.rapidapi.com"
    let apiKey = "e22d4b469bmsh42612ec10a4efebp1d99d9jsnf4f05557412f"
    
    func buildURLRequest(for word: String, path: String? = nil) throws -> URLRequest {
        let headers: [String: String] = [
            "x-rapidapi-key": apiKey,
            "x-rapidapi-host": "wordsapiv1.p.rapidapi.com"
        ]
        
        var urlString = "\(urlBase)/words/\(word)"
        if let path {
            urlString.append("/\(path)")
        }
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        
        return urlRequest
    }
    
    func fetch<T: Decodable>(_ word: String, path: String? = nil) async throws -> T {
        let urlRequest = try buildURLRequest(for: word, path: path)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200 else {
            throw APIError.invalidServerResponse
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
