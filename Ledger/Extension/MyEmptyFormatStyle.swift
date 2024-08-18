//
//  MyEmptyFormatStyle.swift
//  Ledger
//
//  Created by Avi Sanchez on 8/16/24.
//

import Foundation

class MyEmptyFormatStyle<T>: ParseableFormatStyle {
    typealias FormatInput = T
    typealias FormatOutput = T
    
    var parseStrategy = LocalParseStrategy()
    
    func format(_ value: T) -> T {
        return value
    }
    
    func hash(into hasher: inout Hasher) { }
    
    static func == (lhs: MyEmptyFormatStyle, rhs: MyEmptyFormatStyle) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    class LocalParseStrategy: ParseStrategy {
        
        typealias ParseInput = T
        typealias ParseOutput = T
        
        func parse(_ value: ParseInput) throws -> ParseOutput {
            return value
        }
        
        static func == (lhs: LocalParseStrategy, rhs: LocalParseStrategy) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
        
        func hash(into hasher: inout Hasher) { }
    }
}
