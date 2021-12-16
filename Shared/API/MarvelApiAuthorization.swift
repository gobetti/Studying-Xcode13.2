//
//  MarvelApiAuthorization.swift
//  Marvel
//
//  Created by Marcelo Gobetti on 12/10/18.
//

import CryptoKit
import Foundation

// https://developer.marvel.com/documentation/authorization
enum MarvelApiAuthorization {
    private static let publicAPIKey = "<REPLACE ME>"
    private static let privateAPIKey = "<REPLACE ME>"

    private static var timestamp: String {
        return Date().timeIntervalSinceReferenceDate.description
    }

    private static func hash(timestamp: String) -> String {
        let string = timestamp + Self.privateAPIKey + Self.publicAPIKey
        let data = string.data(using: .utf8)!
        return Insecure.MD5.hash(data: data).hexString()
    }

    static var parameters: [String: String] {
        let timestamp = self.timestamp
        return ["apikey": MarvelApiAuthorization.publicAPIKey,
                "ts": timestamp,
                "hash": hash(timestamp: timestamp)]
    }
}

private extension Digest {
    func hexString() -> String {
        self.map { String(format: "%02x", $0) }.joined()
    }
}
