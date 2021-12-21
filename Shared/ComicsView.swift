//
//  ComicsView.swift
//  Xcode13_2
//
//  Created by Marcelo Gobetti on 16/12/21.
//

import SwiftUI

struct ComicsView: View {
    let characterName: String
    let comicItems: [ComicSummary]
    @State private var comics: [Comic?]
    private let service = MarvelService()

    init(characterName: String, comicItems: [ComicSummary]) {
        self.characterName = characterName
        self.comicItems = comicItems
        comics = Array(repeating: nil, count: comicItems.count)
    }
    
    var body: some View {
        NavigationView {
            Group {
                List(comics.indices, id: \.self) { index in
                    if let comic = comics[index] {
                        Cell(comic: comic)
                    } else if comicItems[index].resourceURI != nil {
                        Backport.ProgressView()
                    } else {
                        Text("--")
                    }
                }
            }.backport.navigationTitle(characterName)
        }.onAppear {
            Task {
                await withThrowingTaskGroup(of: Void.self) { group in
                    comicItems.indices.forEach { comicIndex in
                        group.addTask {
                            try await downloadComic(at: comicIndex)
                        }
                    }
                }
            }
        }
    }

    private func downloadComic(at index: Int) async throws {
        guard let resourceURI = comicItems[index].resourceURI else { return }
        comics[index] = try await service.comic(resourceURI: resourceURI)
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
            }.padding(.vertical)
        }
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
