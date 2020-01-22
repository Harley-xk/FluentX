//
//  FluentManager.swift
//  FluentX
//
//  Created by Harley-xk on 2020/1/19.
//

import Foundation
import FluentSQLite

open class FluentManager {
        
    /// default database manager, refers to a default database file on disk
    public static let `default` = FluentManager(storage: .file(path: defaultFilePath.relativePath))
    
    /// memory database manager, will be cleared when this app shuts down
    public static let memory = FluentManager(storage: .memory)
    
    public typealias MigrationProvider = (MigrationContainer) -> ()
    
    /// initialize this database manager, all managers must be initialized before useage
    /// - Parameter migrations: a handler to provide migrations
    public func initialize(migrations: (MigrationContainer) -> ()) throws {
        
        self.database = try SQLiteDatabase(storage: storage)
        self.config.add(database: database, as: idenntifier)

        self.databases = try config.resolve(on: container)
        self.pool = try databases.requireDatabase(for: idenntifier).newConnectionPool(config: .init(maxConnections: maxConnections), on: self.group)


        container.services.register(Logger.self) { _ in
            return PrintLogger()
        }
        container.services.register(databases)

        let container = MigrationContainer(for: idenntifier)
        migrations(container)
        try container.config.prepare(on: self.container).catchFlatMap { (error) -> (EventLoopFuture<Void>) in
            return container.config.revert(on: self.container)
        }.wait()
    }
    
    /// path for default database file
    public static var defaultFilePath: URL {
        let library = try! FileManager.default.url(
            for: .libraryDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let folder = library.appendingPathComponent("FluentX", isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.relativePath) {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        }
        return folder.appendingPathComponent("data.db", isDirectory: false)
    }
    
    // MARK: - Connections
    
    /// Requests a pooled connection.
    ///
    /// The `DatabaseConnection` returned by this method should be released when you are finished using it.
    ///
    /// - returns: A future containing the pooled `DatabaseConnection`.
    func requestConnection() -> Future<SQLiteConnection> {
        return pool.requestConnection()
    }
    
    /// Releases a connection back to the pool. Used with `requestConnection(...)`.
    ///
    /// - parameters:
    ///     - conn: `DatabaseConnection` to release back to the pool.
    func releaseConnection(_ conn: SQLiteConnection) {
        pool.releaseConnection(conn)
    }
    
    /// Fetches a pooled connection.
    ///
    /// The connection is provided to the supplied callback and will be automatically released when the
    /// future returned by the callback is completed.
    ///
    ///     FluentManager.default.withConnection { conn in
    ///         // use the connection
    ///     }
    ///
    /// See `requestConnection(...)` to request a pooled connection without using a callback.
    ///
    /// - parameters:
    ///     - closure: Callback that accepts the pooled `DatabaseConnection`.
    /// - returns: A future containing the result of the closure.
    func withConnection<T>(_ callback: @escaping (SQLiteConnection) -> Future<T>) -> Future<T> {
        return pool.withConnection(callback)
    }
    
    // MARK: - Initialize
    private let storage: SQLiteStorage
    private let maxConnections: Int
    private let group: MultiThreadedEventLoopGroup
    private let idenntifier: DatabaseIdentifier<SQLiteDatabase>
    private var config: DatabasesConfig
    private var container: BasicContainer

    private init(storage: SQLiteStorage, maxConnections: Int = 5) {
        self.storage = storage
        self.maxConnections = maxConnections
        self.group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        self.idenntifier = DatabaseIdentifier(UUID().uuidString)
        self.config = DatabasesConfig()
        self.container = BasicContainer(config: .init(), environment: .testing, services: .init(), on: group)
    }
    
    private var database: SQLiteDatabase!
    private var databases: Databases!    
    public var pool: DatabaseConnectionPool<ConfiguredDatabase<SQLiteDatabase>>!
}
