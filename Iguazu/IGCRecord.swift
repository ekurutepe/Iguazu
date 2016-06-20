//
//  IGCRecord.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 12/06/16.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation
import CoreLocation

protocol IGCRecord {
    var timestamp: Date { get }
}

/// <#Description#>
struct IGCFix: IGCRecord {
    let timestamp: Date
    let coordinate: CLLocationCoordinate2D
    let altimeterAltitude: Int
    let gpsAltitude: Int
    let fixAccuracy: Int
    
    static func parseFix(with line:String) -> IGCFix? {
        guard let prefix = line.extract(from: 0, length: 1) where prefix == "B" else { return nil }
    
        return nil
    }
}

// TODO: create real event type
enum IGCEventType {
    case dummy
}

/// <#Description#>
struct IGCEvent: IGCRecord {
    let timestamp: Date
    let event: IGCEventType
}
