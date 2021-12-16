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

extension URLSession {
    func request(_ endpoint: MarvelApi) async throws -> Data {
        try await data(from: endpoint.makeURL()).0
    }
}

extension MarvelApi {
    var baseURL: URL {
        switch self {
        case .comic(let resourceURI):
            if let path = URL(string: resourceURI)?.path,
                let baseURL = URL(string: resourceURI.replacingOccurrences(of: path, with: "")) {
                return baseURL
            } else {
                fallthrough
            }
        default:
            return URL(string: "https://gateway.marvel.com:443")! // swiftlint:disable:this force_unwrapping
        }
    }

    var path: String {
        switch self {
        case .characters:
            return "/v1/public/characters"
        case .comic(let resourceURI):
            return URL(string: resourceURI)?.path ?? ""
        }
    }

    func makeURL() throws -> URL {
        guard var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
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
