import Vapor
import WebAuthn
import Fluent

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let authRoutes = routes.grouped("auth")
        let appRoutes = authRoutes.grouped("app")
        appRoutes.get("makeCredentials", use: appMakeCredentialsGetHandler)
        appRoutes.post("makeCredentials", use: appMakeCredentialsPostHandler)

        appRoutes.get("authenticate", use: appAuthenticateGetHandler)
        appRoutes.post("authenticate", use: appAuthenticatePostHandler)
    }

    func appMakeCredentialsGetHandler(_ req: Request) async throws -> PublicKeyCredentialCreationOptions {
        throw Abort(.notImplemented)
    }

    func appMakeCredentialsPostHandler(_ req: Request) async throws -> Token {
        throw Abort(.notImplemented)
    }

    func appAuthenticateGetHandler(_ req: Request) async throws -> PublicKeyCredentialRequestOptions {
        throw Abort(.notImplemented)
    }

    func appAuthenticatePostHandler(_ req: Request) async throws -> Token {
        throw Abort(.notImplemented)
    }
}
