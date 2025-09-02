import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @State private var showLoginView = false
    @State private var showRegisterView = false
    @Environment(Auth.self) private var auth
    let apiHostname: String

    var body: some View {
        Group {
            Spacer()
            VStack {
                Text("Welcome to Todos")
                    .font(.largeTitle)
                    .padding()

                Button("Register") {
                    showRegisterView = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .glassEffect()
            }

            Spacer()

            VStack {
                Text("Already have an account?")
                    .padding()
                Button("Log In") {
                    showLoginView = true
                }
            }
        }
        .sheet(isPresented: $showLoginView) {
            LoginView(apiHostname: self.apiHostname)
        }
        .fullScreenCover(isPresented: $showRegisterView) {
            RegisterView(apiHostname: self.apiHostname)
        }
    }
}

#Preview {
    WelcomeView(apiHostname: PasskeyApp.apiHostname).environment(Auth(apiHostname: PasskeyApp.apiHostname))
}
