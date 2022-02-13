//
//  MarvelApi.swift
//  Xcode13_2
//
//  Created by Marcelo Gobetti on 16/12/21.
//

import Foundation

enum MarvelApi {
    case characters(offset: Int)
    case comic(resourceURI: String)
}

extension MarvelApi {
    private static let baseURL = URL(string: "https://gateway.marvel.com:443")! // swiftlint:disable:this force_unwrapping

    var path: String {
        switch self {
        case .characters:
            return "/v1/public/characters"
        case .comic(let resourceURI):
            return URL(string: resourceURI)?.path ?? ""
        }
    }

    func makeURL() throws -> URL {
        guard var urlComponents = URLComponents(url: Self.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw MarvelApiError.invalidPath
        }
        let authParameters = MarvelApiAuthorization.parameters
        let parameters: [String: String]
        switch self {
        case .characters(let offset):
            parameters = authParameters.merging(["offset": "\(offset)"]) { $1 }
        case .comic:
            parameters = authParameters
        }
        urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = urlComponents.url else {
            throw MarvelApiError.invalidParameters
        }
        return url
    }
}

enum MarvelApiError: Error {
    case invalidPath
    case invalidParameters
}
