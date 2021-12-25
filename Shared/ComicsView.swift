//
//  ComicsView.swift
//  Xcode13_2
//
//  Created by Marcelo Gobetti on 16/12/21.
//

import SwiftUI

struct ComicsView: View {
    let characterName: String
    @ObservedObject private var comicsManager: ComicsManager

    init(characterName: String, comicItems: [ComicSummary]) {
        self.characterName = characterName
        comicsManager = ComicsManager(comicItems: comicItems)
    }
    
    var body: some View {
        NavigationView {
            Group {
                List(comicsManager.comics.indices, id: \.self) { index in
                    if let comic = comicsManager.comics[index] {
                        Cell(comic: comic)
                    } else {
                        // TODO: show something if it failed
                        Backport.ProgressView()
                            .onAppear { comicsManager.cellAppeared(at: index) }
                            .onDisappear { comicsManager.cellDisappeared(at: index) }
                    }
                }
            }.backport.navigationTitle(characterName)
        }
    }
}

extension ComicsView {
    struct Cell: View {
        let comic: Comic

        var body: some View {
            HStack(spacing: 8) {
                Backport.AsyncImage(url: comic.thumbnail?.url) { image in
                    image
                        .resizable()
                        .frame(width: 96)
                        .aspectRatio(0.65, contentMode: .fill)
                } placeholder: {
                    Color.gray
                        .frame(width: 96)
                        .aspectRatio(0.65, contentMode: .fill)
                }
                Text(comic.title ?? "Unknown")
            }
            .padding(.vertical)
        }
    }
}

@MainActor
final class ComicsManager: ObservableObject {
    @Published var comics: [Comic?]

    private let resourceURIs: [String]
    private typealias ComicTask = Task<Void, Error>
    private var tasks = [String: ComicTask]()
    private let service = MarvelService()

    init(comicItems: [ComicSummary]) {
        resourceURIs = comicItems.compactMap { $0.resourceURI }
        comics = Array(repeating: nil, count: resourceURIs.count)
    }

    func cellAppeared(at index: Int) {
        let (resourceURI, task) = resourceAndTask(at: index)
        if task?.isCancelled == false { return }
        // TODO: retry if it failed, depending on the failure
        tasks[resourceURI] = Task {
            let comic = try await service.comic(resourceURI: resourceURI)
            try Task.checkCancellation()
            comics[index] = comic
        }
    }

    func cellDisappeared(at index: Int) {
        resourceAndTask(at: index).task?.cancel()
    }

    private func resourceAndTask(at index: Int) -> (resourceURI: String, task: ComicTask?) {
        let resourceURI = resourceURIs[index]
        return (resourceURI, tasks[resourceURI])
    }
}

extension Comic: Identifiable {}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicsView(characterName: "Name", comicItems: [
            .init(resourceURI: "https://picsum.photos/96")
        ])
    }
}
