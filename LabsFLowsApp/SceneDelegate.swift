//
//  SceneDelegate.swift
//  LabsFLowsApp
//
//  Created by Tamara Rodriguez Romo on 13/06/24.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            let contentView = ContentView().environmentObject(AuthViewModel())

            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    // Otros métodos opcionales del protocolo UIWindowSceneDelegate...
}

