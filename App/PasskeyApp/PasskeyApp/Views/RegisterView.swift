import SwiftUI

enum RegisterError: Error {
    case apiError
    case passwordMismatch
}

struct RegisterView: View {
    let apiHostname: String
    @State var name = ""
    @State var email = ""
    @State var password = ""
    @State var passwordConfirmation: String = ""
    @State private var showLoginView = false
    @State private var showAlert = false
    @State private var errorType = RegisterError.apiError

    @Environment(Auth.self) private var auth

    var body: some View {
        VStack {
            Form {
                Text("Register").font(.largeTitle).padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                TextField("Name", text: $name)
                    .padding()
                    .autocapitalization(.words)
                    .textContentType(.name)
                    .padding(.horizontal)
                TextField("Email", text: $email)
                    .padding()
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .padding(.horizontal)
                SecureField("Password", text: $password)
                    .padding()
                    .padding(.horizontal)
                    .textContentType(.newPassword)
                SecureField("Confirm Password", text: $passwordConfirmation)
                    .padding()
                    .padding(.horizontal)
                    .textContentType(.newPassword)
                AsyncButton("Register") {
                    if password != passwordConfirmation {
                        errorType = .passwordMismatch
                        showAlert = true
                        return
                    }
                    await registerUser()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(email.isEmpty || name.isEmpty || password.isEmpty)
            }
            .onSubmit {
                Task {
                    await registerUser()
                }
            }
            VStack {
                Text("Already have an account?")
                    .padding()
                Button("Log In") {
                    showLoginView = true
                }
            }.padding()
        }
        .alert(isPresented: $showAlert) {
            let message = (errorType == .apiError) ? "There was an error registering. Please try again" : "Please ensure your passwords match"
            return Alert(title: Text("Error"), message: Text(message))
        }
        .sheet(isPresented: $showLoginView) {
            LoginView(apiHostname: self.apiHostname)
        }
    }

    func registerUser() async {
        let createUserRequest = CreateUserData(name: name, email: email, password: password)
        do {
            let token = try await ResourceRequest<Token>(apiHostname: self.apiHostname, resourcePath: "users").save(createUserRequest, auth: auth, authRequired: false)
            self.auth.token = token.value
        } catch {
            self.errorType = .apiError
            self.showAlert = true
        }
     }
}

#Preview {
    RegisterView(apiHostname: PasskeyApp.apiHostname).environment(Auth(apiHostname: PasskeyApp.apiHostname))
}
