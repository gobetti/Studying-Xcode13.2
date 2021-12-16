//
//  MarvelApiAuthorization.swift
//  Marvel
//
//  Created by Marcelo Gobetti on 12/10/18.
//

import Foundation
import SwiftHash

// https://developer.marvel.com/documentation/authorization
enum MarvelApiAuthorization {
    private static let publicAPIKey = "<REPLACE ME>"
    private static let privateAPIKey = "<REPLACE ME>"

    private static var timestamp: String {
        return Date().timeIntervalSinceReferenceDate.description
    }

    private static func hash(timestamp: String) -> String {
        return MD5(timestamp + MarvelApiAuthorization.privateAPIKey + MarvelApiAuthorization.publicAPIKey)
            .lowercased()
    }

    static var parameters: [String: String] {
        let timestamp = self.timestamp
        return ["apikey": MarvelApiAuthorization.publicAPIKey,
                "ts": timestamp,
                "hash": hash(timestamp: timestamp)]
    }
}
