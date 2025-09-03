import SwiftUI

struct SettingsView: View {
    @Environment(Auth.self) private var auth
    
    var body: some View {
        Button("Log Out") {
            auth.logout()
        }
    }
}
