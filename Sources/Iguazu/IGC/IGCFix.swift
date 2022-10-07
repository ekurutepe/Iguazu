//
//  IGCFix.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 16/10/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreLocation

/// Representes a fix record in the IGC file.
public struct IGCFix: IGCRecord, CustomStringConvertible {
    public let timestamp: Date
    public let coordinate: CLLocationCoordinate2D
    public let altimeterAltitude: Int
    public let gpsAltitude: Int
    public let fixAccuracy: Int
    public let extensions: [IGCExtension.ExtensionType: Int]
    
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

enum IGCParsingError: Error, Equatable {
    case invalidPrefix
    case invalidTimestamp
    case invalidLatitude
    case invalidLongitude
    case invalidBarometricAltitude
    case invalidGPSAltitude
}

extension IGCFix {
    public init(with line: String, midnight: Date, extensions: [IGCExtension]? = nil) throws {
        guard let prefix = line.extractString(from: 0, length: 1), prefix == "B" else {
            throw IGCParsingError.invalidPrefix
        }
        guard
            let timeString = line.extractString(from: 1, length: 6),
            let timestamp = Date.parse(fixTimeString: timeString, on: midnight)
        else { throw IGCParsingError.invalidTimestamp }

        guard let lat = line.extractLatitude(from: LatitudeOffset) else {
            throw IGCParsingError.invalidLatitude
        }
        guard let lng = line.extractLongitude(from: LongitudeOffset)  else {
            throw IGCParsingError.invalidLongitude
        }
        guard let barometricAltitude = line.extractAltitude(from: AltimeterOffset) else {
            throw IGCParsingError.invalidBarometricAltitude
        }
        guard let gpsAltitude = line.extractAltitude(from: GPSAltitudeOffset) else {
            throw IGCParsingError.invalidGPSAltitude
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        var extensionValues = [IGCExtension.ExtensionType: Int]()
        if let extensions = extensions {
            let keysAndValues = extensions.compactMap { (e) -> (IGCExtension.ExtensionType, Int)? in
                let index = e.startIndex-1
                let length = e.endIndex - e.startIndex + 1
                let type = e.type
                guard let valueString = line.extractString(from: index, length: length),
                    let value = Int(valueString) else { return nil }
                
                return (type, value)
            }
            extensionValues = Dictionary(uniqueKeysWithValues: keysAndValues)
        }

        let accuracy = line.extractAccuracy(from: FixAccucaryOffset)
        
        self.init(timestamp: timestamp,
            coordinate: coordinate,
            altimeterAltitude: barometricAltitude,
            gpsAltitude: gpsAltitude,
            fixAccuracy: accuracy ?? -1,
            extensions: extensionValues)
    }

    public init(with location: CLLocation, altimeterAltitude: Double) {
        self.timestamp = location.timestamp
        self.coordinate = location.coordinate
        self.altimeterAltitude = Int(altimeterAltitude)
        self.gpsAltitude = Int(location.altitude)
        self.fixAccuracy = Int(location.horizontalAccuracy)
        self.extensions = [:]
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

extension IGCFix: Simplifiable {
    public var x: CGFloat {
        return CGFloat(coordinate.latitude)
    }
    
    public var y: CGFloat {
        return CGFloat(coordinate.longitude)
    }
}

