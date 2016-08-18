//
//  IGCParser.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 12/06/16.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation
import CoreLocation

/// Represents an IGC file.
struct IGCData {
    let header: IGCHeader
    let fixes: [IGCFix]
    let extensions: [IGCExtension]?
    
    var locations: [CLLocation] {
        return fixes.map { $0.clLocation }
    }
}

extension IGCData {
    init?(with igcString: String) {
        guard let header = IGCHeader(igcString: igcString) else { return nil }
        
        let lines = igcString.components(separatedBy: .newlines)
        
        let extensions = lines.filter { $0.hasPrefix("I") }
            .flatMap { IGCExtension.parseExtensions(line: $0 ) }.first
        
        let fixes = lines.filter { $0.hasPrefix("B") }
            .map { IGCFix.parseFix(with: $0, midnight: Date()) }
        
        self.init(header: header, fixes: fixes, extensions: extensions)
    }
}
