//
//  CUPRow.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 10.06.19.
//  Copyright © 2019 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

struct CUPRow {
//    Title,Code,Country,Latitude,Longitude,Elevation,Style,Direction,Length,Frequency,Description
//    "LUESSE","EDOJ",DE,5208.652N,01240.182E,65.0m,2,62,1020m,"128.755",""
    let title: String
    let code: String?
    let country: String?
    let latitude: Measurement<UnitAngle>
    let longitue: Measurement<UnitAngle>
    let elevation: Measurement<UnitLength>
    let style: Int?
    let direction: Int?
    let length: Measurement<UnitLength>?
    let frequency: String?
    let description: String?
}

extension CUPRow {
    init?(_ row: String) {
        let components = row.components(separatedBy: ",")
        //    "001SPLuesse",,XX,5208.650N,01240.100E,66m,5,,,,
        guard components.count == 11 else { return nil }
        self.title = components[0].replacingOccurrences(of: "\"", with: "")
        self.code = components[1].replacingOccurrences(of: "\"", with: "")
        self.country = components[2].replacingOccurrences(of: "\"", with: "")

        guard let latitude = Measurement<UnitAngle>(latitudeString: components[3]) else { return nil }
        self.latitude = latitude

        guard let longitude = Measurement<UnitAngle>(longitudeString: components[4]) else { return nil }
        self.longitue = longitude

        guard let elevation = Measurement<UnitLength>(components[5]) else { return nil }
        self.elevation = elevation

        self.style = Int(components[6])

        self.direction = Int(components[7])

        self.length = Measurement<UnitLength>(components[8])

        self.frequency = components[9].replacingOccurrences(of: "\"", with: "")

        self.description = components[10].replacingOccurrences(of: "\"", with: "")
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
