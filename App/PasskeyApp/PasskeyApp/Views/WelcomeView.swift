import SwiftUI
import AuthenticationServices

struct WelcomeView: View {
    @State private var showLoginView = false
    @State private var showRegisterView = false
    @State private var passkeyError = false
    @Environment(Auth.self) private var auth
    @Environment(\.authorizationController) private var authorizationController

    var body: some View {
        Group {
            Spacer()
            VStack {
                Text("Welcome to Todos")
                    .font(.largeTitle)
                    .padding()

                AsyncButton("Register") {
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
            LoginView()
        }
        .fullScreenCover(isPresented: $showRegisterView) {
            RegisterView()
        }
        .alert(isPresented: $passkeyError) {
            return Alert(title: Text("Error"), message: Text("There was a problem registering with a passkey. Please try again or register with email and password"))
        }
        .task {
            try? await checkForPasskey()
        }
    }

    func attemptPasskeySignup() async throws {

    }

    func checkForPasskey() async throws {

    }
}

#Preview {
    WelcomeView().environment(Auth())
}
