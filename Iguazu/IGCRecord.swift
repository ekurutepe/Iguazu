//
//  IGCRecord.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 12/06/16.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation
import CoreLocation


/// Basic protocol all record types need to conform to.
protocol IGCRecord {
    var timestamp: Date { get }
}

/// Representes a fix record in the IGC file.
struct IGCFix: IGCRecord {
    let timestamp: Date
    let coordinate: CLLocationCoordinate2D
    let altimeterAltitude: Int
    let gpsAltitude: Int
    let fixAccuracy: Int
    
    private static let TimeOffset = 1
    private static let LatitudeOffset = 7
    private static let LongitudeOffset = 15
    private static let AltimeterOffset = 25
    private static let GPSAltitudeOffset = 30
    private static let FixAccucaryOffset = 35
    
    static func parseFix(with line:String, midnight: Date) -> IGCFix {
        guard let prefix = line.extractString(from: 0, length: 1), prefix == "B",
            let timeComponents = line.extractTime(from: TimeOffset),
            let timestamp = Calendar.current.date(byAdding: timeComponents, to: midnight),
            let lat = line.extractLatitude(from: LatitudeOffset),
            let lng = line.extractLongitude(from: LongitudeOffset),
            let barometricAltitude = line.extractAltitude(from: AltimeterOffset),
            let gpsAltitude = line.extractAltitude(from: GPSAltitudeOffset),
            let accuracy = line.extractAccuracy(from: FixAccucaryOffset) else { fatalError("could not parse line: \(line)") } // TODO: throw here instead of fatalError
        
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

