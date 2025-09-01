import Foundation

@Observable
class Auth {
    static let keychainKey = "TIL-API-KEY"
    
    private(set) var isLoggedIn = false
    
    let apiHostname: String
    
    init(apiHostname: String) {
        self.apiHostname = apiHostname
        if token != nil {
            self.isLoggedIn = true
        }
    }
    
    var token: String? {
        get {
            Keychain.load(key: Auth.keychainKey)
        }
        set {
            if let newToken = newValue {
                Keychain.save(key: Auth.keychainKey, data: newToken)
            } else {
                Keychain.delete(key: Auth.keychainKey)
            }
            DispatchQueue.main.async {
                self.isLoggedIn = newValue != nil
            }
        }
    }
    
    func logout() {
        token = nil
    }
    
    func login(username: String, password: String) async throws -> String {
        let path = "\(apiHostname)/api/users/login"
        guard let url = URL(string: path) else {
            fatalError("Failed to convert URL")
        }
        guard
            let loginString = "\(username):\(password)"
                .data(using: .utf8)?
                .base64EncodedString()
        else {
            fatalError("Failed to encode credentials")
        }
        
        var loginRequest = URLRequest(url: url)
        loginRequest.addValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        loginRequest.httpMethod = "POST"
        
        let (data, response) = try await URLSession.shared.data(for: loginRequest)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AuthError.badResponse
        }
        
        let token = try JSONDecoder().decode(Token.self, from: data)
        return token.value
    }
}
