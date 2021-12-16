//
//  CharactersView.swift
//  Shared
//
//  Created by Marcelo Gobetti on 16/12/21.
//

import SwiftUI

struct CharactersView: View {
    @State private var characters: [Character]
    private let service = MarvelService()

    init(characters: [Character] = []) {
        self.characters = characters
    }

    var body: some View {
        NavigationView {
            Group {
                if characters.isEmpty {
                    ProgressView()
                } else {
                    List(characters) { character in
                        Cell(character: character)
                    }
                }
            }.navigationTitle("Characters")
        }.onAppear {
            Task {
                characters = try await service.characters()
            }
        }
    }
}

private extension CharactersView {
    struct Cell: View {
        let character: Character
        private var name: String { character.name ?? "Unknown" }
        var body: some View {
            if let comicItems = character.comics?.items, !comicItems.isEmpty {
                NavigationLink(destination: ComicView(characterName: name, comicItems: comicItems)) {
                    Content(name: name)
                }
            } else {
                Content(name: name)
            }
        }
    }
}

private extension CharactersView.Cell {
    struct Content: View {
        let name: String
        var body: some View {
            Text(name)
        }
    }
}

extension Character: Identifiable {}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CharactersView(characters: [
            .init(id: 1, name: "Name", comics: .init(items: [
                .init(resourceURI: nil)
            ]))
        ])
    }
}
