//
//  Airport.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 10.06.19.
//  Copyright © 2019 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

public struct Airport {
    let title: String
    let code: String
    let country: String
    let latitude: Double
    let longitude: Double
    let elevation: Measurement<UnitLength>
    let direction: Int?
    let length: Measurement<UnitLength>?
    let frequency: String?
}

public extension Airport {
    static func airports(withContentsOf url: URL) -> [Airport] {
        var cupString = ""
        do {
            cupString = try String(contentsOf: url, encoding: .ascii)
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
