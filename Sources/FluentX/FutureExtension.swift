//
//  FutureExtension.swift
//  FluentX-Example-iOS
//
//  Created by Harley-xk on 2020/1/22.
//  Copyright © 2020 Harley. All rights reserved.
//

import Foundation
import FluentSQLite

public extension Future {
    
    /// do callback action when this future is finished
    /// - Parameters:
    ///   - queue: callback will be performed on this queue, defaults to main queue
    ///   - callback: callback actions
    func finally(on queue: DispatchQueue = .main, callback: @escaping (Result<T, Error>) -> ()) {
        self.do { (value) in
            queue.async {
                callback(.success(value))
            }
        }.catch { (error) in
            queue.async {
                callback(.failure(error))
            }
        }
    }
}
