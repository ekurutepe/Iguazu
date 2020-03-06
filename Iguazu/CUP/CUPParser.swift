//
//  CUPParser.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 01.03.20.
//

import Foundation

public final class CUPParser {
    static public func pointOfInterest(from row: String, sourceIdentifier: String?) -> PointOfInterest? {
        func oddNumberOfQuotes(_ string: String) -> Bool {
            return string.components(separatedBy: "\"").count % 2 == 0
        }

        let rawComponents = row.components(separatedBy: ",")

        // Adapted from https://github.com/Daniel1of1/CSwiftV/blob/develop/Sources/CSwiftV/CSwiftV.swift
        var components = [String]()
        for newString in rawComponents {
            guard let record = components.last , oddNumberOfQuotes(record) == true else {
                components.append(newString)
                continue
            }
            components.removeLast()
            let lastElem = record + "," + newString
            components.append(lastElem)
        }

        //    "001SPLuesse",,XX,5208.650N,01240.100E,66m,5,,,,
        guard
            components.count >= 11,
            let latitude = Measurement<UnitAngle>(latitudeString: components[3])?.value,
            let longitude = Measurement<UnitAngle>(longitudeString: components[4])?.value
        else {
            return nil
        }

        let elevation = Measurement<UnitLength>(components[5]) ?? Measurement<UnitLength>("0m")!
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
        do {
            let fileContents = try String(contentsOf: fileURL)
            let lines = Array(fileContents.components(separatedBy: .newlines).dropFirst())
            self.points = lines.concurrentMap { (line) -> PointOfInterest? in
                    guard !line.isEmpty else { return nil }
                    return CUPParser.pointOfInterest(from: line, sourceIdentifier: fileURL.lastPathComponent)
                }
                .compactMap { $0 }
        } catch {
            print("could not parse file:", fileURL, error)
            assertionFailure()
            return nil
        }

    }

    var airports: [Airport] {
        return points.filter {
            [PointOfInterest.Style.airfieldGliding, .airfieldGrass, .airfieldPaved].contains($0.style)
        }
    }

}
