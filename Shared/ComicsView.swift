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
                try await withThrowingTaskGroup(of: Comic.self) { group in
                    for (offset, element) in comicItems.enumerated() {
                        guard let resourceURI = element.resourceURI else { return }
                        group.addTask {
                            try await service.comic(resourceURI: resourceURI)
                        }
                        // I think this `await` makes it so the next task is only added once this one is done,
                        // but ideally I wanted to start them all (or up to N) at once and populate the appropriate `comics` index
                        for try await comic in group {
                            comics[offset] = comic
                        }
                    }
                }
            }
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
