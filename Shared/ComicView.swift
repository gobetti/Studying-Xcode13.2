//
//  ComicView.swift
//  Xcode13_2
//
//  Created by Marcelo Gobetti on 16/12/21.
//

import SwiftUI

struct ComicView: View {
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
                List(comics.indices) { index in
                    if let comic = comics[index] {
                        Text(comic.title ?? "Unknown")
                    } else if comicItems[index].resourceURI != nil {
                        ProgressView()
                    } else {
                        Text("--")
                    }
                }
            }.navigationTitle(characterName)
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

extension Comic: Identifiable {}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicView(characterName: "Name", comicItems: [
            .init(resourceURI: nil)
        ])
    }
}
