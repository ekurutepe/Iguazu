//
//  IGCExtension.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 14/06/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

public struct IGCExtension {
    public enum ExtensionType: String {
        case fixAccuracy = "FXA"
        case engineNoiseLevel = "ENL"
        case trueAirspeed = "TAS"
        case totalEnergy = "VAT"
    }

    let startIndex: Int
    let endIndex: Int
    let type: ExtensionType

    static func parseExtensions(line: String) -> [IGCExtension]? {
        
        guard let firstChar = line.first else { return nil }

        guard firstChar == "I" || firstChar == "J" else { return nil }

        guard let extensionCount = Int(line.extractString(from: 1, length: 2) ?? "") else { return nil }

        let extensionCharLength = 7

        let extensionsString = line.dropFirst(3)

        var extensions = [IGCExtension]()

        for i in 0 ..< extensionCount {
            guard let firstByte = Int(extensionsString.extractString(from: (i * extensionCharLength), length: 2) ?? "") else { continue }
            guard let secondByte = Int(extensionsString.extractString(from: (i * extensionCharLength) + 2, length: 2) ?? "") else { continue }
            let code = extensionsString.extractString(from: (i * extensionCharLength) + 4, length: 3) ?? ""

            guard let type = ExtensionType(rawValue: code) else { continue }

            let ext = IGCExtension(startIndex: firstByte, endIndex: secondByte, type: type)

            extensions.append(ext)
        }

        return extensions
    }
}
