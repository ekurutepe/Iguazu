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
    
    static func parseFix(with line:String, midnight: Date) -> IGCFix {
        guard let prefix = line.extractString(from: 0, length: 1), prefix == "B",
            let timeComponents = line.extractTime(from: 1),
            let timestamp = Calendar.current.date(byAdding: timeComponents, to: midnight),
            let lat = line.extractLatitude(from: 7),
            let lng = line.extractLongitude(from: 15),
            let barometricAltitude = line.extractAltitude(from: 25),
            let gpsAltitude = line.extractAltitude(from: 30),
            let accuracy = line.extractAccuracy(from: 35) else { fatalError("could not parse line: \(line)") } // TODO: throw here instead of fatalError
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)

        return IGCFix(timestamp: timestamp,
            coordinate: coordinate,
            altimeterAltitude: barometricAltitude,
            gpsAltitude: gpsAltitude,
            fixAccuracy: accuracy)
    }
    
    var clLocation: CLLocation {
        return CLLocation.init(coordinate: coordinate,
            altitude: CLLocationDistance(altimeterAltitude),
            horizontalAccuracy: CLLocationAccuracy(fixAccuracy),
            verticalAccuracy: -1,
            timestamp: timestamp)
    }
}

// TODO: create real event type
enum IGCEventType {
    case dummy
}

///
struct IGCEvent: IGCRecord {
    let timestamp: Date
    let event: IGCEventType
}
