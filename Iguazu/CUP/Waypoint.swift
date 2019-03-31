//
//  Waypoint.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 31.03.19.
//  Copyright © 2019 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

public struct Waypoint {
    public let title: String
    public let code: String
    public let latitude: Double
    public let longitude: Double
    public let elevation: Double
}

public extension Waypoint {
    static func waypoints(withContentsOf url: URL) -> [Waypoint] {
        var cupString = ""
        do {
            cupString = try String(contentsOf: url, encoding: .ascii)
        }
        catch _ {
            return []
        }
        return waypoints(from: cupString)
    }
    
    static func waypoints(from string: String) -> [Waypoint] {
        let rows = string.components(separatedBy: .newlines)
        guard rows.count > 1 else { return [] }
//    Title,Code,Country,Latitude,Longitude,Elevation,Style,Direction,Length,Frequency,Description
//        let header = rows.first!
        let wps = rows.dropFirst()
        return wps.compactMap { Waypoint(cupRow: $0) }

    }
    

    init?(cupRow: String) {
        let components = cupRow.components(separatedBy: ",")
//    "001SPLuesse",,XX,5208.650N,01240.100E,66m,5,,,,
        guard components.count > 5 else { return nil }
        self.title = components[0].replacingOccurrences(of: "\"", with: "")
        self.code = components[1].replacingOccurrences(of: "\"", with: "")
        
        let latStringNS = components[3]
        let lngStringEW = components[4]
        let elevString = components[5]
        let NS = latStringNS.last
        let latString = latStringNS.dropLast()
        let latSign = (NS == "N") ? 1.0 : -1.0
        guard let latDegrees = Double(latString.prefix(2)),
            let latMinutes = Double(latString.dropFirst(2)) else { return nil }
        
        self.latitude = latSign * (latDegrees + latMinutes/60.0)

        let EW = lngStringEW.last
        
        let lngString = lngStringEW.dropLast()

        guard let lngDegrees = Double(lngString.prefix(3)),
            let lngMinutes = Double(lngString.dropFirst(3)) else { return nil }
        let lngSign = (EW == "E") ? 1.0 : -1.0
        self.longitude = lngSign * (lngDegrees + lngMinutes/60.0)

        self.elevation = Double(elevString) ?? 0.0
    }
}
