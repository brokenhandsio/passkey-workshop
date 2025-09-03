import Vapor
import WebAuthn
import Fluent

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let authRoutes = routes.grouped("auth")
        let appRoutes = authRoutes.grouped("app")
    }
}
