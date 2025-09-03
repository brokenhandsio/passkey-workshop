import Fluent
import FluentSQLiteDriver
import Vapor
import WebAuthn

// configures your application
public func configure(_ app: Application) async throws {
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    app.middleware.use(app.sessions.middleware)
    app.sessions.use(.memory)

    app.migrations.add(CreateUser())
    app.migrations.add(CreateTodo())
    app.migrations.add(CreateToken())
    app.migrations.add(CreateAdminUser())
    app.migrations.add(CreateWebAuthnCredential())

    try await app.autoMigrate()

    // register routes
    try routes(app)
}
