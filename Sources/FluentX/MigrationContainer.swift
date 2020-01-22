//
//  MigrationContainer.swift
//  FluentX-Example-iOS
//
//  Created by Harley-xk on 2020/1/20.
//  Copyright © 2020 Harley. All rights reserved.
//

import Foundation
import FluentSQLite

public class MigrationContainer {
    
    internal var config: MigrationConfig
    internal var database: DatabaseIdentifier<SQLiteDatabase>
    
    internal init(for database: DatabaseIdentifier<SQLiteDatabase>) {
        self.config = MigrationConfig()
        self.database = database
    }
    
    public func add<M: Model>(model: M.Type)
        where M: Migration, M.Database == SQLiteDatabase
    {
        config.add(model: model, database: database)
    }
    
    public func add<M: Migration>(migration: M.Type)
        where M.Database == SQLiteDatabase
    {
        config.add(migration: migration, database: database)
    }
}
