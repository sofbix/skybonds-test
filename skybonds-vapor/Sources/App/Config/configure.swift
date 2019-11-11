import Vapor
import FluentSQLite

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    
    /// Register providers first
    try services.register(FluentSQLiteProvider())
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
    
    
    
    let dbStorge = SQLiteStorage.file(path: "skybonds.sqlite")
    let dbSkybonds = try SQLiteDatabase(storage: dbStorge)
    
    var databases = DatabasesConfig()
    databases.add(database: dbSkybonds, as: .sqlite)
    services.register(databases)
    
    var migrations = MigrationConfig()
    migrations.add(model: PriceEntity.self, database: .sqlite)
    services.register(migrations)
    
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
}
