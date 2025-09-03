import Vapor
import WebAuthn
import Fluent

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let authRoutes = routes.grouped("auth")
        let appRoutes = authRoutes.grouped("app")

        appRoutes.post("makeCredentials", use: appMakeCredentialsPostHandler)
        appRoutes.get("makeCredentials", use: appMakeCredentialsGetHandler)
        appRoutes.get("authenticate", use: appAuthenticateGetHandler)
        appRoutes.post("authenticate", use: appAuthenticatePostHandler)
    }

    func appMakeCredentialsGetHandler(_ req: Request) async throws -> PublicKeyCredentialCreationOptions {
        let userID = UUID().uuidString
        let webAuthnUser = PublicKeyCredentialUserEntity(id: [UInt8](Data(userID.utf8)), name: "", displayName: "")
        let options = req.webAuthn.beginRegistration(user: webAuthnUser)
        req.session.data["registrationChallenge"] = Data(options.challenge).base64EncodedString()
        req.session.data["userID"] = userID
        return options
    }

    // Create a function for the second route
    func appMakeCredentialsPostHandler(_ req: Request) async throws -> Token {
        // Obtain the challenge we stored on the server for this session
        guard let challengeEncoded = req.session.data["registrationChallenge"],
              let challenge = Data(base64Encoded: challengeEncoded), let userIDString = req.session.data["userID"], let userID = UUID(uuidString: userIDString) else {
            throw Abort(.badRequest, reason: "Missing registration session ID")
        }

        // Nil out challenge to avoic replay attacks
        req.session.data["registrationChallenge"] = nil

        let completeRegistrationData = try req.content.decode(CompletePasskeyRegistration.self)

        let credential = try await req.webAuthn.finishRegistration(
            challenge: [UInt8](challenge),
            credentialCreationData: completeRegistrationData.credential,
            confirmCredentialIDNotRegisteredYet: { credentialID in
                let existingCredential = try await WebAuthnCredential.query(on: req.db)
                    .filter(\.$id == credentialID)
                    .first()
                return existingCredential == nil
            }
        )

        let user = User(id: userID, name: completeRegistrationData.name, email: completeRegistrationData.email, passwordHash: UUID().uuidString, userType: .normal)
        try await user.save(on: req.db)

        try await WebAuthnCredential(from: credential, userID: userID).save(on: req.db)

        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }

    func appAuthenticateGetHandler(_ req: Request) async throws -> PublicKeyCredentialRequestOptions {
        let options = try req.webAuthn.beginAuthentication()
        req.session.data["authChallenge"] = Data(options.challenge).base64EncodedString()
        return options
    }

    func appAuthenticatePostHandler(_ req: Request) async throws -> Token {
        // Obtain the challenge we stored on the server for this session
        guard let challengeEncoded = req.session.data["authChallenge"],
              let challenge = Data(base64Encoded: challengeEncoded) else {
            throw Abort(.badRequest, reason: "Missing auth session ID")
        }

        // Delete the challenge from the server to prevent attackers from reusing it
        req.session.data["authChallenge"] = nil

        // Decode the credential the client sent us
        let authenticationCredential = try req.content.decode(AuthenticationCredential.self)

        // find the credential the stranger claims to possess
        guard let credential = try await WebAuthnCredential.query(on: req.db)
            .filter(\.$id == authenticationCredential.id.urlDecoded.asString())
            .with(\.$user)
            .first() else {
            throw Abort(.unauthorized)
        }

        // if we found a credential, use the stored public key to verify the challenge
        let verifiedAuthentication = try req.webAuthn.finishAuthentication(
            credential: authenticationCredential,
            expectedChallenge: [UInt8](challenge),
            credentialPublicKey: [UInt8](URLEncodedBase64(credential.publicKey).urlDecoded.decoded!),
            credentialCurrentSignCount: credential.currentSignCount
        )

        // if we successfully verified the user, update the sign count
        credential.currentSignCount = verifiedAuthentication.newSignCount
        try await credential.save(on: req.db)

        // finally authenticate the user
        req.auth.login(credential.user)

        let token = try credential.user.generateToken()
        try await token.save(on: req.db)
        return token
    }

}
