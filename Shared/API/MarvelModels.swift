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

protocol ResultsContainer: Codable {
    associatedtype MarvelType: Codable
    var results: [MarvelType]? { get }
}

struct DataWrapper<DataContainer: ResultsContainer>: Codable {
    let data: DataContainer?
}

struct CharacterResultsContainer: ResultsContainer {
    let results: [Character]?
}

struct ComicResultsContainer: ResultsContainer {
    let results: [Comic]?
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
    let thumbnail: Image?

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

struct Image: Codable {
    let path: String?
    let `extension`: ImageExtension?
}

enum ImageExtension: String, Codable {
    case gif
    case jpg
    case png
}
