//
//  Logger.swift
//  QRCodeReaderApp
//
//  Created by Eliezer Rodrigo Beltramin de Sant Ana on 27/07/23.
//

import Foundation

public enum LoggerError: Int, Error {
    case unknown = 37000
    
    // JAB
    case soapError = 37010
    case hashValidationError = 37011
    case unexpectedCodigoRetorno = 37012
    
    public init(_ status: Int, function: String = #function,
                file: String = #file, line: Int = #line) {
        self = LoggerError(rawValue: status) ?? .unknown
    }
    public init(_ type: LoggerError, function: String = #function, file: String = #file, line: Int = #line) {
        self = type
    }
}

public struct Logger {
    public static func err(_ error: Error?,
                           name: String = "",
                           value: String = ".",
                           info: [AnyHashable: Any]? = nil,
                           function: String = #function, file: NSString = #file, line: Int = #line) {
        
        let err = error ?? LoggerError(.unknown)
        
        NSLog("\n[ERROR]\t\(name)::\(file.lastPathComponent):\(line) >>\(function)\n\(value)\n")
    }
    
    public static func err(_ name: String = "",
                           _ value: String? = nil,
                           info: [AnyHashable: Any]? = nil,
                           function: String = #function, file: NSString = #file, line: Int = #line) {
        
        err(nil, name: name, value: value ?? ".", info: info, function: function, file: file, line: line)
    }
    
    public static func err(_ error: CFError,
                           name: String = "",
                           value: String = ".",
                           info: [AnyHashable: Any]? = nil,
                           function: String = #function, file: NSString = #file, line: Int = #line) {
        
        if let asErr = error as? Error {
            err(asErr, name: name, value: value, info: info, function: function, file: file, line: line)
        }
    }
    
    public static func dbg(_ text: String = "", function: String = #function, file: NSString = #file, line: Int = #line) {
        let filename = file.lastPathComponent
        
        NSLog("\n[DBG]\t\(filename):\(line) >>\(function)\n\(text)\n")
    }
    
    public static func dbg(_ variavel: Any?, function: String = #function, file: NSString = #file, line: Int = #line) {
        let filename = file.lastPathComponent
        let showing = (variavel == nil) ? "nil" : variavel!
        
        NSLog("\n[DBG]\t\(filename):\(line) >>\(function)\n\(type(of: showing)):\(showing)\n")
    }
    
    public static func dbg(_ text: String = "", _ variavel: Any?, function: String = #function, file: NSString = #file, line: Int = #line) {
        let filename = file.lastPathComponent
        let showing = (variavel == nil) ? "nil" : variavel!
        
        NSLog("\n[DBG]\t\(filename):\(line) >>\(function)\n\(text)\t\(type(of: showing)):\(showing)\n")
    }
    
}
