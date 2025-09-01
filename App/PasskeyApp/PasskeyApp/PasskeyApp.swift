//
//  PasskeyAppApp.swift
//  PasskeyApp
//
//  Created by Tim Condon on 31/08/2025.
//

import SwiftUI

@main
struct PasskeyApp: App {
    static let apiHostname = "http://localhost:8080"

    @State
    var auth = Auth(apiHostname: PasskeyApp.apiHostname)

    var body: some Scene {
        WindowGroup {
              if auth.isLoggedIn {
                TabView {
                  TodosView(apiHostname: PasskeyApp.apiHostname)
                    .tabItem {
                      Label("Todos", systemImage: "abc")
                    }
                    TodosView(apiHostname: PasskeyApp.apiHostname, myTodos: true)
                      .tabItem {
                        Label("My Todos", systemImage: "abc")
                      }
                }
                .environment(auth)
              } else {
                LoginView(apiHostname: PasskeyApp.apiHostname).environment(auth)
              }
            }
    }
}
