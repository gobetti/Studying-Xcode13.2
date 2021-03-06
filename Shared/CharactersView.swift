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
    private let tasks = NSMutableDictionary()

    init(characters: [Character] = []) {
        self.characters = characters
    }

    var body: some View {
        NavigationView {
            Group {
                if characters.isEmpty {
                    Backport.ProgressView()
                } else {
                    List(characters) { character in
                        Cell(character: character)
                    }
                }
            }.backport.navigationTitle("Characters")
        }
        .adjustNavigationViewStyleForIPad()
        .backport.task(cache: tasks) {
            do {
                characters = try await service.characters()
            } catch {
                assertionFailure("FIXME: Unhandled network error - \(error.localizedDescription)")
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
                NavigationLink(destination: ComicsView(characterName: name, comicItems: comicItems)) {
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

private extension View {
    @ViewBuilder func adjustNavigationViewStyleForIPad() -> some View {
        #if os(macOS)
        self
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.navigationViewStyle(DoubleColumnNavigationViewStyle())
                .padding()
        } else {
            self
        }
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CharactersView(characters: [
            .init(id: 1, name: "Name", comics: .init(items: [
                .init(resourceURI: nil)
            ]))
        ])
    }
}
