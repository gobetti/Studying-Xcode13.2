//
//  MarvelService.swift
//  Marvel
//
//  Created by Marcelo Gobetti on 13/10/18.
//

import Foundation
import RxCocoaNetworking
import RxSwift

enum MarvelServiceError: Error {
    case noComic
}

struct MarvelService {
    private let provider: Provider<MarvelApi>

    init(stubBehavior: StubBehavior = .never,
         scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .background)) {
        provider = Provider(stubBehavior: stubBehavior, scheduler: scheduler)
    }

    func characters(offset: Int = 0) -> Single<[Character]> {
        return provider.request(.characters(offset: offset))
            .mapToDataWrapper()
            .map { (dataWrapper: DataWrapper<CharacterResultsContainer>) -> [Character] in
                guard let characters = dataWrapper.data?.results else { return [] }
                return characters
            }
    }

    func comic(resourceURI: String) -> Single<Comic> {
        return provider.request(.comic(resourceURI: resourceURI))
            .mapToDataWrapper()
            .map { (dataWrapper: DataWrapper<ComicResultsContainer>) -> Comic in
                guard let comic = dataWrapper.data?.results?.first else {
                    throw MarvelServiceError.noComic
                }
                return comic
            }
    }
}

private extension PrimitiveSequence where TraitType == SingleTrait, ElementType == Data {
    func mapToDataWrapper<T>() -> Single<DataWrapper<T>> {
        return map { data -> DataWrapper<T> in
            let decoder = Decoding.decoder
            return try decoder.decode(DataWrapper<T>.self, from: data)
        }
    }
}
