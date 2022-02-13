//
//  APIClient.swift
//  Xcode13_2
//
//  Created by Marcelo Gobetti on 12/02/22.
//

import Foundation
import URLSessionBackport

// For now we only support GET endpoints thus `data(from: URL)` is fine.
// TODO: Consider something like https://kean.blog/post/new-api-client once more power is needed.
extension URLSession {
    func request(_ endpoint: MarvelApi) async throws -> Data {
        let (data, response) = try await backport.data(from: endpoint.makeURL())
        if let httpResponse = response as? HTTPURLResponse {
            guard (200..<300).contains(httpResponse.statusCode) else { throw APIClientError.unacceptableStatusCode(httpResponse.statusCode) }
        }
        return data
    }
}

enum APIClientError: LocalizedError {
    case unacceptableStatusCode(Int)
    
    var errorDescription: String? {
        switch self {
        case .unacceptableStatusCode(let statusCode): return "Server responded with \(statusCode)" // TODO: localize
        }
    }
}
