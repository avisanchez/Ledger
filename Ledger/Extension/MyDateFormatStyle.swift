//
//  MyDateFormatStyle.swift
//  Ledger
//
//  Created by Avi Sanchez on 8/13/24.
//

import Foundation

class MyDateFormatStyle: ParseableFormatStyle {
    
    typealias FormatInput = Date
    typealias FormatOutput = String
    
    var parseStrategy = LocalParseStrategy()
    
    let dateFormat: String
    
    init(dateFormat: String) {
        self.dateFormat = dateFormat
    }
    
    func format(_ value: Date) -> String {
        return DateFormatter(dateFormat: dateFormat).string(from: value)
    }
    
    func hash(into hasher: inout Hasher) { }
    
    static func == (lhs: MyDateFormatStyle, rhs: MyDateFormatStyle) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    class LocalParseStrategy: ParseStrategy {
        
        typealias ParseInput = String
        typealias ParseOutput = Date
        
        func parse(_ value: ParseInput) throws -> ParseOutput {
            return DateFormatter(dateFormat: Constants.dateFormat).date(from: value) ?? .now
        }
        
        static func == (lhs: LocalParseStrategy, rhs: LocalParseStrategy) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
        
        func hash(into hasher: inout Hasher) { }
    }
}
