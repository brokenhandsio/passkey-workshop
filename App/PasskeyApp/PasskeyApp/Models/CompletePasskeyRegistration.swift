import Foundation

struct CompletePasskeyRegistration: Codable {
    let name: String
    let email: String
    let credential: RegistrationCredential
}
