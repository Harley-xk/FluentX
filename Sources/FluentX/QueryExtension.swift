//
//  Query.swift
//  FluentX-Example-iOS
//
//  Created by Harley-xk on 2020/1/22.
//  Copyright © 2020 Harley. All rights reserved.
//

import Foundation
import FluentSQLite

extension Model where Database == SQLiteDatabase {
    
    static func find(_ id: Self.ID, on manager: FluentManager = .default) -> Future<Self?> {
        manager.withConnection { (connection) -> EventLoopFuture<Self?> in
            return self.query(on: connection).filter(idKey == id).first()
        }
    }
    
    func update(on manager: FluentManager = .default) -> Future<Self> {
        manager.withConnection { self.update(on: $0) }
    }
    
    func create(on manager: FluentManager = .default) -> Future<Self> {
        manager.withConnection { self.create(on: $0) }
    }
}

public extension Array where Element: Model {
    func save(on manager: FluentManager = .default) -> Future<Self> {
        return manager.withConnection { (conn) -> EventLoopFuture<Self> in
            return self.compactMap { $0.save(on: conn) }.flatten(on: conn)
        }
    }
}
