//
//  SceneDelegate.swift
//  Shared
//
//  Created by Marcelo Gobetti on 16/12/21.
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let window = (scene as? UIWindowScene).map { UIWindow(windowScene: $0) } ?? UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: CharactersView())
        self.window = window
        window.makeKeyAndVisible()
    }
}
