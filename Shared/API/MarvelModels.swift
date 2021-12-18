//
//  MarvelModels.swift
//  Marvel
//
//  Created by Marcelo Gobetti on 12/10/18.
//

import Foundation

enum Decoding {
    static let decoder: JSONDecoder = {
        $0.dateDecodingStrategy = .formatted(dateFormatter)
        return $0
    }(JSONDecoder())

    static let dateFormatter: DateFormatter = {
        $0.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return $0
    }(DateFormatter())
}

struct ResultsContainer<Result: Codable>: Codable {
    let results: [Result]?
}

struct DataWrapper<Result: Codable>: Codable {
    let data: ResultsContainer<Result>?
}

struct Character: Codable, Equatable {
    let id: Int?
    let name: String?
    let comics: ComicList?

    static func == (lhs: Character, rhs: Character) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Comic: Codable, Equatable {
    let id: Int?
    let title: String?
    let description: String?
    let thumbnail: ComicImage?

    static func == (lhs: Comic, rhs: Comic) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ComicList: Codable {
    let items: [ComicSummary]?
}

struct ComicSummary: Codable {
    let resourceURI: String?
}

struct ComicImage: Codable {
    let path: String?
    let `extension`: ImageExtension?

    var url: URL? {
        guard let path = path, let baseURL = URL(string: path.replacingOccurrences(of: "http://", with: "https://")), let rawExtension = `extension`?.rawValue else { return nil }
        return baseURL.appendingPathExtension(rawExtension)
    }
}

enum ImageExtension: String, Codable {
    case gif
    case jpg
    case png
}
