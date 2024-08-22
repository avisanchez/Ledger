//
//  AccountFile.swift
//  Ledger
//
//  Created by Avi Sanchez on 8/21/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct AccountFile: FileDocument {
    static var readableContentTypes = [UTType.propertyList]
    
    var contents: CDAccount = .placeholder
    
    init(_ account: CDAccount) {
        contents = account
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            contents = try PropertyListDecoder().decode(CDAccount.self, from: data)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try PropertyListEncoder().encode(contents)
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.preferredFilename = contents.name
        return wrapper
    }
    
    
}
