//
//  IGCFix.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 16/10/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation
import CoreLocation

/// Representes a fix record in the IGC file.
public struct IGCFix: IGCRecord, CustomStringConvertible {
    public let timestamp: Date
    public let coordinate: CLLocationCoordinate2D
    public let altimeterAltitude: Int
    public let gpsAltitude: Int
    public let fixAccuracy: Int
    
    public var clLocation: CLLocation {
        return CLLocation(
            coordinate: coordinate,
            altitude: CLLocationDistance(altimeterAltitude),
            horizontalAccuracy: CLLocationAccuracy(fixAccuracy),
            verticalAccuracy: -1,
            timestamp: timestamp)
    }
    
    public var description: String {
        return "\(timestamp), lat: \(coordinate.latitude), lng: \(coordinate.longitude), alt: \(altimeterAltitude)"
    }
}

private let TimeOffset = 1
private let LatitudeOffset = 7
private let LongitudeOffset = 15
private let AltimeterOffset = 25
private let GPSAltitudeOffset = 30
private let FixAccucaryOffset = 35

extension IGCFix {
    public init(with line: String, midnight: Date) {
        guard let prefix = line.extractString(from: 0, length: 1), prefix == "B",
            let timeString = line.extractString(from: 1, length: 6),
            let timestamp = Date.parse(fixTimeString: timeString, on: midnight),
            let lat = line.extractLatitude(from: LatitudeOffset),
            let lng = line.extractLongitude(from: LongitudeOffset),
            let barometricAltitude = line.extractAltitude(from: AltimeterOffset),
            let gpsAltitude = line.extractAltitude(from: GPSAltitudeOffset),
            let accuracy = line.extractAccuracy(from: FixAccucaryOffset) else { fatalError("could not parse line: \(line)") } // TODO: throw here instead of fatalError
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        self.init(timestamp: timestamp,
            coordinate: coordinate,
            altimeterAltitude: barometricAltitude,
            gpsAltitude: gpsAltitude,
            fixAccuracy: accuracy)
    }

    public init(with location: CLLocation, altimeterAltitude: Double) {
        self.timestamp = location.timestamp
        self.coordinate = location.coordinate
        self.altimeterAltitude = Int(altimeterAltitude)
        self.gpsAltitude = Int(location.altitude)
        self.fixAccuracy = Int(location.horizontalAccuracy)
    }
    
    public var bLine: String {
        let time = self.timestamp.igcFixTime
        
        let latitude = self.coordinate.latitude
        let northSouth = (latitude > 0) ? "N" : "S"
        let latDegrees = String(format: "%02d", abs(Int(latitude)))
        let latMinutes = String(format: "%05d", Int(round(1000 * abs(latitude - Double(Int(latitude))) * 60.0)))
        
        let longitude = self.coordinate.longitude
        let eastWest = (longitude > 0) ? "E" : "W"
        let lonDegrees = String(format: "%03d", abs(Int(longitude)))
        let lonMinutes = String(format: "%05d", Int(round(1000 * abs(longitude - Double(Int(longitude))) * 60.0)))
        
        let gpsAltitude = String(format: "%05d", self.gpsAltitude)
        let altimeterAltitude = String(format: "%05d", self.altimeterAltitude)
        
        let fixAccuracy = String(format: "%03d", self.fixAccuracy)
        
        return "B\(time)\(latDegrees)\(latMinutes)\(northSouth)\(lonDegrees)\(lonMinutes)\(eastWest)A\(altimeterAltitude)\(gpsAltitude)\(fixAccuracy)"
    }
}

