//
//  ComicView.swift
//  Xcode13_2
//
//  Created by Marcelo Gobetti on 16/12/21.
//

import SwiftUI

struct ComicView: View {
    let characterName: String
    let comicSummary: ComicSummary
    @State private var comic: Comic?
    private let service = MarvelService()
    
    var body: some View {
        NavigationView {
            Group {
                if let comic = comic {
                    Text(comic.title ?? "Unknown")
                } else if comicSummary.resourceURI != nil {
                    ProgressView()
                } else {
                    Text("Nothing to display.")
                }
            }.navigationTitle(characterName)
        }.onAppear {
            guard let resourceURI = comicSummary.resourceURI else { return }
            Task {
                comic = try await service.comic(resourceURI: resourceURI)
            }
        }
    }
}

struct ComicView_Previews: PreviewProvider {
    static var previews: some View {
        ComicView(characterName: "Name", comicSummary: .init(resourceURI: nil))
    }
}
