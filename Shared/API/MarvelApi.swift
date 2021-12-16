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

extension MarvelApi: ProductionTargetType {
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

    var task: Task {
        let authParameters = MarvelApiAuthorization.parameters

        switch self {
        case .characters(let offset):
            let parameters = ["offset": "\(offset)"]
            return Task(parameters: authParameters.merging(parameters) { _, new in new })
        case .comic:
            return Task(parameters: authParameters)
        }
    }
}
