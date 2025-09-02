import SwiftUI

@main
struct PasskeyApp: App {
    static let apiHostname = "https://demos.brokenhands.ngrok.app"
    static let appDomain = "demos.brokenhands.ngrok.app"

    @State
    var auth = Auth(apiHostname: PasskeyApp.apiHostname)

    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                TabView {
                    TodosView(apiHostname: PasskeyApp.apiHostname)
                        .tabItem {
                            Label("Todos", systemImage: "list.bullet")
                        }
                    TodosView(apiHostname: PasskeyApp.apiHostname, myTodos: true)
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
                WelcomeView(apiHostname: PasskeyApp.apiHostname).environment(auth)
            }
        }
    }
}
