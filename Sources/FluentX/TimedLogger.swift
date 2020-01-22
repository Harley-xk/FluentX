//
//  TimedLogger.swift
//  App
//
//  Created by Harley-xk on 2019/2/21.
//

import Foundation
import FluentSQLite

final class PrintLogger: Logger, Service {
    func log(_ string: String, at level: LogLevel, file: String, function: String, line: UInt, column: UInt) {
        Swift.print("[\(Date.timeStampForLogger)][\(level)] \(string)")
    }
    
    func log(_ level: LogLevel, message: String) {
        log(message, at: level, file: "", function: "", line: 0, column: 0)
    }
    
}

extension Date {
    
    static var timeStampForLogger: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
}
