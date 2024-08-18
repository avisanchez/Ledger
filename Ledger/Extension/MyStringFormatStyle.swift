//
//  NumberFormatter.swift
//  Ledger
//
//  Created by Avi Sanchez on 5/28/24.
//

import Foundation

class MyStringFormatStyle: ParseableFormatStyle {
    
    typealias FormatInput = String
    typealias FormatOutput = String
    
    var parseStrategy = LocalParseStrategy()
    
    func format(_ value: String) -> String {
        return value
    }
    
    func hash(into hasher: inout Hasher) { }
    
    static func == (lhs: MyStringFormatStyle, rhs: MyStringFormatStyle) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    class LocalParseStrategy: ParseStrategy {
        
        typealias ParseInput = String
        typealias ParseOutput = String
        
        func parse(_ value: ParseInput) throws -> ParseOutput {
            return value
        }
        
        static func == (lhs: LocalParseStrategy, rhs: LocalParseStrategy) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
        
        func hash(into hasher: inout Hasher) { }
    }
}
