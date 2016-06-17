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
        
        let extensionStartIndex = line.index(countIndex, offsetBy: 2)
        guard let extensionCount = Int(line.substring(with: countIndex..<extensionStartIndex)) else { return nil }
        
        let extensionCharCount = 7
        
        var extensions = [IGCExtension]()
        
        for i in 0..<extensionCount {
            let firstByteIndex = line.index(extensionStartIndex, offsetBy: i*extensionCharCount)
            let secondByteIndex = line.index(firstByteIndex, offsetBy: 2)
            let codeIndex = line.index(secondByteIndex, offsetBy: 2)
            
            guard let firstByte = Int(line.substring(with: firstByteIndex..<secondByteIndex)) else { break }
            guard let secondByte = Int(line.substring(with: secondByteIndex..<codeIndex)) else { break }
            guard let type = ExtensionType(rawValue: line.substring(with: codeIndex..<line.index(codeIndex, offsetBy: 3))) else { break }
            
            let ext = IGCExtension(startIndex: firstByte, endIndex: secondByte, type: type)
            
            extensions.append(ext)
        }
        
        return extensions
    }
}
