import SwiftUI

@main
struct PasskeyApp: App {
    static let apiHostname = "https://demos.brokenhands.ngrok.app"
    static let appDomain = "demos.brokenhands.ngrok.app"
    
    @State
    var auth = Auth()
    
    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                TabView {
                    TodosView()
                        .tabItem {
                            Label("Todos", systemImage: "list.bullet")
                        }
                    TodosView(myTodos: true)
                        .tabItem {
                            Label("My Todos", systemImage: "checklist")
                        }
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .environment(auth)
            } else {
                WelcomeView().environment(auth)
            }
        }
    }
}
