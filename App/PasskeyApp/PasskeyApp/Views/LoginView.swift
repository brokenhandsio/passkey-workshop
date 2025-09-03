import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @State var username = ""
    @State var password = ""
    @State private var showingLoginErrorAlert = false
    @State private var showingProgressView = false
    @Environment(Auth.self) private var auth
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Log In")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
            Form {
                TextField("Username", text: $username)
                    .padding()
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal)
                    .textContentType(.username)
                    .autocorrectionDisabled()
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .padding(.horizontal)
                AsyncButton("Log In") {
                    showingProgressView = true
                    if let token = await login() {
                        auth.token = token
                    }
                    showingProgressView = false
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(username.isEmpty || password.isEmpty)
            }
            .onSubmit {
                Task {
                    await login()
                }
            }
            VStack {
                Button("Cancel") {
                    dismiss()
                }
            }.padding()
        }
        .alert(isPresented: $showingLoginErrorAlert) {
            Alert(title: Text("Error"), message: Text("Could not log in. Check your credentials and try again"))
        }
        .overlay {
            if showingProgressView {
                ProgressView("Logging In...")
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(10)
            }
        }
    }
    
    @MainActor
    func login() async -> String? {
        do {
            let token = try await auth.login(username: username, password: password)
            return token
        } catch {
            self.showingLoginErrorAlert = true
            return nil
        }
    }
}

#Preview {
    LoginView().environment(Auth())
}
