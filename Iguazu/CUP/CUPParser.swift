//
//  CUPParser.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 01.03.20.
//

import Foundation

public final class CUPParser {
    static public func pointOfInterest(from row: String, sourceIdentifier: String?) -> PointOfInterest? {
        let components = row.components(separatedBy: ",")
        //    "001SPLuesse",,XX,5208.650N,01240.100E,66m,5,,,,
        guard
            components.count == 11,
            let latitude = Measurement<UnitAngle>(latitudeString: components[3])?.value,
            let longitude = Measurement<UnitAngle>(longitudeString: components[4])?.value,
            let elevation = Measurement<UnitLength>(components[5])
        else { return nil }

        var p = PointOfInterest(
            title: components[0].replacingOccurrences(of: "\"", with: ""),
            code: components[1].replacingOccurrences(of: "\"", with: ""),
            country: components[2].replacingOccurrences(of: "\"", with: ""),
            latitude: latitude,
            longitude: longitude,
            elevation: elevation,
            style: PointOfInterest.Style(rawValue: Int(components[6]) ?? 0) ?? .unknown,
            direction: Int(components[7]),
            length: Measurement<UnitLength>(components[8]),
            frequency: components[9].replacingOccurrences(of: "\"", with: ""),
            description: components[10].replacingOccurrences(of: "\"", with: ""))
        p.sourceIdentifier = sourceIdentifier
        return p
    }
}

public struct CUPFile {
    public let name: String
    public let points: [PointOfInterest]
}

public extension CUPFile {
    init?(name: String, fileURL: URL) {
        self.name = name
        guard let fileContents = try? String(contentsOf: fileURL) else { return nil }
        let lines = fileContents.components(separatedBy: .newlines)
        self.points = lines.concurrentMap { (line) -> PointOfInterest? in
                CUPParser.pointOfInterest(from: line, sourceIdentifier: fileURL.lastPathComponent)
            }
            .compactMap { $0 }
    }

    var airports: [Airport] {
        return points.filter {
            [PointOfInterest.Style.airfieldGliding, .airfieldGrass, .airfieldPaved].contains($0.style)
        }
    }

}
