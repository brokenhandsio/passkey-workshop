import SwiftUI

struct RegisterView: View {
    let apiHostname: String
    @State var name = ""
    @State var email = ""
    @State var password = ""
    @State var passwordConfirmation: String = ""
    @State private var showingPasswordErrorAlert = false
    @State private var showLoginView = false
    @State private var showingCreateError = false
    @Environment(Auth.self) private var auth

    var body: some View {
        VStack {
            Text("Register").font(.largeTitle).padding()
            TextField("Name", text: $name)
                .padding()
                .autocapitalization(.words)
                .textContentType(.name)
                .padding(.horizontal)
            TextField("Email", text: $email)
                .padding()
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .padding(.horizontal)
            SecureField("Password", text: $password)
                .padding()
                .padding(.horizontal)
            SecureField("Confirm Password", text: $password)
                .padding()
                .padding(.horizontal)
            AsyncButton("Register") {
                if password != passwordConfirmation {
                    showingPasswordErrorAlert = true
                    return
                }
                try await registerUser()
            }
            .disabled(email.isEmpty || name.isEmpty || password.isEmpty)
            VStack {
                Text("Already have an account?")
                    .padding()
                Button("Log In") {
                    showLoginView = true
                }
            }.padding()
        }
        .alert(isPresented: $showingPasswordErrorAlert) {
            Alert(title: Text("Error"), message: Text("Please ensure your passwords match"))
        }
        .alert(isPresented: $showingCreateError) {
            Alert(title: Text("Error"), message: Text("There was an error registering. Please try again"))
        }
        .sheet(isPresented: $showLoginView) {
            LoginView(apiHostname: self.apiHostname)
        }
    }

    func registerUser() async throws {
        let createUserRequest = CreateUserData(name: name, email: email, password: password)
        do {
            let token = try await ResourceRequest<Token>(apiHostname: self.apiHostname, resourcePath: "users").save(createUserRequest, auth: auth)
            self.auth.token = token.value
        } catch {
            self.showingCreateError = true
        }
    }
}

#Preview {
    RegisterView(apiHostname: PasskeyApp.apiHostname).environment(Auth(apiHostname: PasskeyApp.apiHostname))
}
