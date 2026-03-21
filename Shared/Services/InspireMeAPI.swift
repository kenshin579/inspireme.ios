import Foundation

actor InspireMeAPI {
    static let baseURL = "https://inspire-me.advenoh.pe.kr"

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchQuoteOfTheDay(lang: String = "ko") async throws -> Quote {
        let url = URL(string: "\(Self.baseURL)/api/widget/quote-of-the-day?lang=\(lang)")!
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(QuoteResponse.self, from: data)
        return response.data
    }

    func searchTopics(query: String, lang: String = "ko") async throws -> [String] {
        var urlString = "\(Self.baseURL)/api/widget/topics?lang=\(lang)"
        if !query.isEmpty {
            urlString += "&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)"
        }
        let url = URL(string: urlString)!
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(TopicsResponse.self, from: data)
        return response.data
    }

    func fetchRandomQuote(lang: String = "ko", topics: [String]? = nil) async throws -> Quote {
        var urlString = "\(Self.baseURL)/api/widget/random?lang=\(lang)&count=1"
        if let topics, !topics.isEmpty {
            urlString += "&topics=\(topics.joined(separator: ","))"
        }
        let url = URL(string: urlString)!
        let (data, _) = try await session.data(from: url)
        let response = try JSONDecoder().decode(QuoteResponse.self, from: data)
        return response.data
    }
}
