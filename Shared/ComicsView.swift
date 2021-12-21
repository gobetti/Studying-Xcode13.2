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
                    } else if comicsManager.comicItems[index].resourceURI != nil {
                        Backport.ProgressView()
                            .onAppear { comicsManager.cellAppeared(at: index) }
                            .onDisappear { comicsManager.cellDisappeared(at: index) }
                    } else {
                        Text("--")
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
    let comicItems: [ComicSummary]
    @Published var comics: [Comic?]
    private var tasks: [Task<Void, Error>?]
    private let service = MarvelService()

    init(comicItems: [ComicSummary]) {
        self.comicItems = comicItems
        tasks = Array(repeating: nil, count: comicItems.count)
        comics = Array(repeating: nil, count: comicItems.count)
    }

    func cellAppeared(at index: Int) {
        guard let resourceURI = comicItems[index].resourceURI else { return }
        if let existingTask = tasks[index], !existingTask.isCancelled { return }
        // TODO: retry if it failed
        tasks[index] = Task {
            let comic = try await service.comic(resourceURI: resourceURI)
            try Task.checkCancellation()
            comics[index] = comic
        }
    }

    func cellDisappeared(at index: Int) {
        tasks[index]?.cancel()
    }
}

extension Comic: Identifiable {}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicsView(characterName: "Name", comicItems: [
            .init(resourceURI: nil)
        ])
    }
}
