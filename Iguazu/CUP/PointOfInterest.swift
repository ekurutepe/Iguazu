//
//  PointOfInterest.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 10.06.19.
//  Copyright © 2019 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

public typealias Airport = PointOfInterest
public typealias Waypoint = PointOfInterest

public struct PointOfInterest: Equatable, Codable {
//    Title,Code,Country,Latitude,Longitude,Elevation,Style,Direction,Length,Frequency,Description
//    "LUESSE","EDOJ",DE,5208.652N,01240.182E,65.0m,2,62,1020m,"128.755",""
    public let title: String
    public let code: String?
    public let country: String?
    public let latitude: Double
    public let longitude: Double
    public let elevation: Measurement<UnitLength>
    public let style: Style
    public let direction: Int?
    public let length: Measurement<UnitLength>?
    public let frequency: String?
    public let description: String?
    public var sourceIdentifier: String? 

    public enum Style: Int, Codable {
        case unknown = 0
        case waypoint
        case airfieldGrass
        case outlanding
        case airfieldGliding
        case airfieldPaved
        case mountainPass
        case mountainTop
        case mast
        case vor
        case ndb
        case coolingTower
        case dam
        case tunnel
        case bridge
        case powerPlant
        case castle
        case intersection
    }

    public init(title: String, code: String?, country: String?, latitude: Double, longitude: Double, elevation: Measurement<UnitLength>, style: Style, direction: Int?, length: Measurement<UnitLength>?, frequency: String?, description: String?) {
        self.title = title
        self.code = code
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.style = style
        self.direction = direction
        self.length = length
        self.frequency = frequency
        self.description = description
    }
}

extension Measurement where UnitType == UnitAngle {
    init?(latitudeString: String) {
        guard latitudeString.hasSuffix("N") || latitudeString.hasSuffix("S") else { return nil }

        let NS = latitudeString.last
        let degreesString = latitudeString.dropLast()
        let latSign = (NS == "N") ? 1.0 : -1.0
        guard let latDegrees = Double(degreesString.prefix(2)),
            let latMinutes = Double(degreesString.dropFirst(2)) else { return nil }

        self = Measurement<UnitAngle>(value: latSign * (latDegrees + latMinutes/60.0), unit: .degrees)
    }

    init?(longitudeString: String) {
        guard longitudeString.hasSuffix("E") || longitudeString.hasSuffix("W") else { return nil }

        let EW = longitudeString.last
        let degreesString = longitudeString.dropLast()
        let lonSign = (EW == "E") ? 1.0 : -1.0
        guard let lonDegrees = Double(degreesString.prefix(3)),
            let lon = Double(degreesString.dropFirst(3)) else { return nil }

        self = Measurement<UnitAngle>(value: lonSign * (lonDegrees + lon/60.0), unit: .degrees)
    }
}


extension Measurement where UnitType == UnitLength {
    init?(_ string: String) {
        let unit: UnitLength
        let digits: String
        if string.hasSuffix("ft") {
            unit = .feet
            digits = string.dropLast(2).trimmingCharacters(in: .whitespaces)
        } else {
            unit = .meters
            if string.hasSuffix("m") {
                digits = string.dropLast(1).trimmingCharacters(in: .whitespaces)
            } else {
                digits = string.trimmingCharacters(in: .whitespaces)
            }
        }

        guard let value = Double(digits) else { return nil }
        self = Measurement<UnitLength>(value: value, unit: unit)
    }
}
