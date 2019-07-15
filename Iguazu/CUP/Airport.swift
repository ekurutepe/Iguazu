//
//  Airport.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 10.06.19.
//  Copyright © 2019 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

public struct Airport {
    public let title: String
    public let code: String
    public let country: String
    public let latitude: Double
    public let longitude: Double
    public let elevation: Measurement<UnitLength>
    public let direction: Int?
    public let length: Measurement<UnitLength>?
    public let frequency: String?
}

public extension Airport {
    static func airports(withContentsOf url: URL) -> [Airport] {
        var cupString = ""
        do {
            cupString = try String(contentsOf: url, encoding: .utf8)
        }
        catch _ {
            return []
        }
        return airports(from: cupString)
    }

    static func airports(from string: String) -> [Airport] {
        let rows = string.components(separatedBy: .newlines)
        guard rows.count > 1 else { return [] }
        //    Title,Code,Country,Latitude,Longitude,Elevation,Style,Direction,Length,Frequency,Description
        //        let header = rows.first!
        let wps = rows.dropFirst()
        return wps.compactMap { Airport(row: $0) }

    }
}

private extension Airport {
    init?(row: String) {
        guard let cup = CUPRow(row) else { return nil }
        self = Airport(
            title: cup.title,
            code: cup.code ?? "",
            country: cup.country ?? "",
            latitude: cup.latitude.converted(to: .degrees).value,
            longitude: cup.longitue.converted(to: .degrees).value,
            elevation: cup.elevation,
            direction: cup.direction,
            length: cup.length,
            frequency: cup.frequency)

    }
}
