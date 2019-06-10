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
        return wps.compactMap { Waypoint(row: $0) }

    }
}

private extension Waypoint {
    init?(row: String) {
        guard let cup = CUPRow(row) else { return nil }
        self = Waypoint(
            title: cup.title,
             code: cup.code ?? "",
             latitude: cup.latitude.converted(to: .degrees).value,
             longitude: cup.longitue.converted(to: .degrees).value,
             elevation: cup.elevation.converted(to: .meters).value)
    }
}
