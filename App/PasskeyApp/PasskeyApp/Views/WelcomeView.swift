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
                    try await attemptPasskeySignup()
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
        .onAppear {
            Task {
                try await checkForPasskey()
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

    func attemptPasskeySignup() async throws {
        let makeCredentialsData = try await PasskeyRequests.getPasskeyRegistrationFromServer()

        let provider = ASAuthorizationAccountCreationProvider()
        let request = provider.createPlatformPublicKeyCredentialRegistrationRequest(
            acceptedContactIdentifiers: [.email],
            shouldRequestName: true,
            relyingPartyIdentifier: PasskeyApp.appDomain,
            challenge: Data(makeCredentialsData.challenge),
            userID: Data(makeCredentialsData.user.id)
        )

        do {
            let result = try await authorizationController.performRequest(request)
            if case .passkeyAccountCreation(let account) = result {
                let data = try await PasskeyRequests.completePasskeyRegistration(account: account)
                let token = try JSONDecoder().decode(Token.self, from: data)
                self.auth.token = token.value
            }
        } catch
            ASAuthorizationError.deviceNotConfiguredForPasskeyCreation {
            showRegisterView = true
        } catch ASAuthorizationError.canceled {
            showRegisterView = true
        } catch {
            passkeyError = true
            throw error
        }
    }

    func checkForPasskey() async throws {
        let assertionData = try await PasskeyRequests.getAssertionData()
        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: PasskeyApp.appDomain)
        let platformKeyRequest = platformProvider.createCredentialAssertionRequest(challenge: Data(assertionData.challenge))
        do {
            // ...
            let result = try await authorizationController.performRequest(platformKeyRequest, options: .preferImmediatelyAvailableCredentials)
            if case .passkeyAssertion(let assertion) = result {
                let data = try await PasskeyRequests.completePasskeyAssertion(assertion: assertion)
                let token = try JSONDecoder().decode(Token.self, from: data)
                self.auth.token = token.value
            }
        } catch ASAuthorizationError.deviceNotConfiguredForPasskeyCreation {
            // Nothing to do, keep displaying the welcome form
        } catch ASAuthorizationError.canceled {
            // Nothing to do, keep displaying the welcome form
        } catch {
            passkeyError = true
            throw error
        }
    }
}

#Preview {
    WelcomeView().environment(Auth())
}
