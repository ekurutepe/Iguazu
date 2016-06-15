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
struct IGCLocation: IGCRecord {
    let timestamp: Date
    let coordinate: CLLocationCoordinate2D
    let altimeterAltitude: Int
    let gpsAltitude: Int
    let fixAccuracy: Int
    let extensions: [IGCExtension]?
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
