import SwiftUI
import AuthenticationServices

struct LoginView: View {
    let apiHostname: String
    @State var username = ""
    @State var password = ""
    @State private var showingLoginErrorAlert = false
    @Environment(Auth.self) private var auth
    
    var body: some View {
        VStack {
            Image("logo")
                .aspectRatio(contentMode: .fit)
                .padding(.leading, 75)
                .padding(.trailing, 75)
            Text("Log In")
                .font(.largeTitle)
            TextField("Username", text: $username)
                .padding()
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .border(Color("rw-dark"), width: 1)
                .padding(.horizontal)
            SecureField("Password", text: $password)
                .padding()
                .border(Color("rw-dark"), width: 1)
                .padding(.horizontal)
            AsyncButton("Log In") {
                if let token = await login() {
                    auth.token = token
                }
            }
            .frame(width: 120.0, height: 60.0)
            .disabled(username.isEmpty || password.isEmpty)
        }
        .alert(isPresented: $showingLoginErrorAlert) {
            Alert(title: Text("Error"), message: Text("Could not log in. Check your credentials and try again"))
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
    LoginView(apiHostname: PasskeyApp.apiHostname).environment(Auth(apiHostname: PasskeyApp.apiHostname))
}
