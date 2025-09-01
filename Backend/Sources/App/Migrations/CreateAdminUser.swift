import Fluent
import Vapor

struct CreateAdminUser: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let passwordHash = try Bcrypt.hash("password123")
        let adminUser = User(name: "Admin User", email: "admin@example.com", passwordHash: passwordHash, userType: .admin)
        try await adminUser.save(on: database)
    }

    func revert(on database: any Database) async throws {
        try await User.query(on: database).filter(\.$email == "admin@example.com").delete()
    }
}
