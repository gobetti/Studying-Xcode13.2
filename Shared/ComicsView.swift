//
//  ComicsView.swift
//  Xcode13_2
//
//  Created by Marcelo Gobetti on 16/12/21.
//

import SwiftUI

struct ComicsView: View {
    let characterName: String
    @State private var comics: [Comic?]
    private let resourceURIs: [String]
    private let service = MarvelService()
    private let tasks = NSMutableDictionary()

    init(characterName: String, comicItems: [ComicSummary]) {
        self.characterName = characterName
        resourceURIs = comicItems.compactMap { $0.resourceURI }
        comics = Array(repeating: nil, count: resourceURIs.count)
    }
    
    var body: some View {
        NavigationView {
            Group {
                List(comics.indices, id: \.self) { index in
                    if let comic = comics[index] {
                        Cell(comic: comic)
                    } else {
                        // TODO: show something if it failed
                        Backport.ProgressView()
                            .backport.task(cache: tasks) {
                                let resourceURI = resourceURIs[index]
                                do {
                                    comics[index] = try await service.comic(resourceURI: resourceURI)
                                } catch {
                                    assertionFailure("Handle network errors")
                                }
                            }
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

extension Comic: Identifiable {}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicsView(characterName: "Name", comicItems: [
            .init(resourceURI: "https://picsum.photos/96")
        ])
    }
}
