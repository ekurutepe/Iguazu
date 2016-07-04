//
//  IGCExtension.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 14/06/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

struct IGCExtension {
    
    enum ExtensionType: String {
        case fixAccuracy = "FXA"
        case engineNoiseLevel = "ENL"
    }
    
    let startIndex: Int
    let endIndex: Int
    let type: ExtensionType
    
    static func parseExtensions(line: String) -> [IGCExtension]? {
        let countIndex = line.index(after: line.startIndex)
        let firstChar = line.substring(to: countIndex)
        
        guard firstChar == "I" || firstChar == "J" else { return nil }
        
        guard let extensionCount = Int(line.extractString(from: 1, length: 2) ?? "") else { return nil }
        
        let extensionCharLength = 7
        
        let extensionsString = line.substring(from: line.index(countIndex, offsetBy: 2))
        
        var extensions = [IGCExtension]()
        
        for i in 0..<extensionCount {
            guard let firstByte = Int(extensionsString.extractString(from: (i*extensionCharLength), length: 2) ?? "") else { break }
            guard let secondByte = Int(extensionsString.extractString(from: (i*extensionCharLength)+2, length: 2) ?? "") else { break }
            let code = extensionsString.extractString(from: (i*extensionCharLength)+4, length: 3) ?? ""
            
            guard let type = ExtensionType(rawValue: code) else { break }
            
            let ext = IGCExtension(startIndex: firstByte, endIndex: secondByte, type: type)
            
            extensions.append(ext)
        }
        
        return extensions
    }
}
