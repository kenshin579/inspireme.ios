import Foundation

struct Quote: Codable, Sendable, Identifiable {
    let id: String
    let content: String
    let author: String
    let authorSlug: String
    let language: String
    let topics: [String]
    let tags: [String]?
}

struct QuoteResponse: Codable, Sendable {
    let data: Quote
}

struct QuotesResponse: Codable, Sendable {
    let data: [Quote]
}
