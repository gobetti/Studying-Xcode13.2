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
        List(characters) { character in
            Text(character.name ?? "Unknown")
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
