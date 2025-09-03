import Vapor
@preconcurrency import WebAuthn

struct CompletePasskeyRegistration: Content {
    let name: String
    let email: String
    let credential: RegistrationCredential

    func encode(to encoder: any Encoder) throws {
        // Not needed here
    }
}

