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
        let dataWrapper: DataWrapper<CharacterResultsContainer> =
        try await URLSession.shared.request(.characters(offset: offset))
            .toDataWrapper()
        return dataWrapper.data?.results ?? []
    }

    func comic(resourceURI: String) async throws -> Comic {
        let dataWrapper: DataWrapper<ComicResultsContainer> =
        try await URLSession.shared.request(.comic(resourceURI: resourceURI))
            .toDataWrapper()
        guard let comic = dataWrapper.data?.results?.first else { throw MarvelServiceError.noComic }
        return comic
    }
}

private extension Data {
    func toDataWrapper<T>() throws -> DataWrapper<T> {
        let decoder = Decoding.decoder
        return try decoder.decode(DataWrapper<T>.self, from: self)
    }
}
