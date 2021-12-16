//
//  MarvelService.swift
//  Marvel
//
//  Created by Marcelo Gobetti on 13/10/18.
//

import Foundation

enum MarvelServiceError: Error {
    case noComic
}

struct MarvelService {
    // TODO: come back to unit testing later
//    private let provider: Provider<MarvelApi>
//
//    init(stubBehavior: StubBehavior = .never,
//         scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)) {
//        provider = Provider(stubBehavior: stubBehavior, scheduler: scheduler)
//    }

    func characters(offset: Int = 0) async throws -> [Character] {
        try await URLSession.shared.request(.characters(offset: offset))
            .toDataWrapper()
            .data?.results ?? []
    }

    func comic(resourceURI: String) async throws -> Comic {
        try (await URLSession.shared.request(.comic(resourceURI: resourceURI))
            .toDataWrapper()
            .data?.results?.first).unwrap(orError: MarvelServiceError.noComic)
    }
}

private extension Data {
    func toDataWrapper<T>() throws -> DataWrapper<T> {
        let decoder = Decoding.decoder
        return try decoder.decode(DataWrapper<T>.self, from: self)
    }
}

private extension Optional {
    func unwrap(orError error: @autoclosure () -> Error) throws -> Wrapped {
        guard let unwrapped = self else { throw error() }
        return unwrapped
    }
}
