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
                        Text(character.name ?? "Unknown")
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
