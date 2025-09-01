import SwiftUI

struct RegisterView: View {
    let apiHostname: String
    @State var name = ""
    @State var email = ""
    @State var password = ""
    @State var passwordConfirmation: String = ""
    @State private var showingPasswordErrorAlert = false
    @State private var showLoginView = false
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
                    
                }
//                if let token = await login() {
//                    auth.token = token
//                }
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
        .sheet(isPresented: $showLoginView) {
            LoginView(apiHostname: self.apiHostname)
        }
    }
}

#Preview {
    RegisterView(apiHostname: PasskeyApp.apiHostname).environment(Auth(apiHostname: PasskeyApp.apiHostname))
}
