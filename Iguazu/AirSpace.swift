//
//  AirSpace.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 10/12/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation
import CoreLocation

public enum AirSpaceClass: String {
    case Alpha = "A"
    case Bravo = "B"
    case Charlie = "C"
    case Delta = "D"
    case Restricted = "R"
    case Danger = "Q"
    case Prohibited = "P"
    case GliderProhibited = "GP"
    case CTR = "CTR"
    case WaveWindow = "W"
    case TransponderMandatoryZone = "TMZ"
    case RadioMandatoryZone = "RMZ"
}

public typealias AirSpacesByClassDictionary = [AirSpaceClass: [AirSpace]]

public typealias Altitude = Measurement<UnitLength>

public typealias DegreeComponents = Array<String>

public extension Collection where Iterator.Element == String {
    var degree: CLLocationDegrees {
        return self.enumerated().map { (n,c) in
            let idx = Double(n)
            guard let value = Double(c.trimmingCharacters(in: CharacterSet.whitespaces)) else { fatalError("not convertible to degrees: '\(c)'") }
            return value * pow(60.0, -idx)
            }
            .reduce(0.0, +)
    }
}

public enum AirSpaceAltitude {
    case surface
    case agl(altitude: Altitude)
    case msl(altitude: Altitude)
    case fl(flightLevel: Int)
    
    init?(_ string: String) {
        let lowercase = string.lowercased()
        if lowercase == "gnd" || lowercase == "sfc" {
            self = .surface
            return
        }
        
        let impliedMSLString: String
        if let mslRange = lowercase.range(of: "msl") {
            impliedMSLString = lowercase.replacingCharacters(in: mslRange, with: "")
        } else {
            impliedMSLString = lowercase
        }
        
        guard let value = Int(impliedMSLString.trimmingCharacters(in: CharacterSet.decimalDigits.inverted).trimmingCharacters(in: .whitespaces)) else { return nil }

        if impliedMSLString.hasPrefix("fl") {
            self = .fl(flightLevel: value)
            return
        }
        
        let unit: UnitLength
        
        if impliedMSLString.contains("m") {
            unit = .meters
        } else {
            unit = .feet
        }
        
        if impliedMSLString.hasSuffix("agl") {
            self = .agl(altitude: Altitude(value: Double(value), unit: unit))
            return
        }
        
        self = .msl(altitude: Altitude(value: Double(value), unit: unit))
        return
    }
}

public struct AirSpace {
    public let `class`: AirSpaceClass
    public let ceiling: AirSpaceAltitude
    public let floor: AirSpaceAltitude
    public let name: String
    public let labelCoordinates: [CLLocationCoordinate2D]?
    public let polygonCoordinates: [CLLocationCoordinate2D]
}

public extension AirSpace {
    private struct ParserState {
        var x: CLLocationCoordinate2D?
        var clockwise = true
    }
    
    private struct AirSpaceInProgress {
        var `class`: AirSpaceClass? = nil
        var ceiling: AirSpaceAltitude? = nil
        var floor: AirSpaceAltitude? = nil
        var name: String? = nil
        var labelCoordinates: [CLLocationCoordinate2D]? = nil
        var polygonCoordinates = [CLLocationCoordinate2D]()
        
        var validAirSpace: AirSpace? {
            guard let klass = self.class,
                let ceiling = self.ceiling,
                let floor = self.floor,
                let name = self.name,
                polygonCoordinates.count > 2 else { return nil }
            
            //            dump(polygonCoordinates)
            return AirSpace(class: klass,
                            ceiling: ceiling,
                            floor: floor,
                            name: name,
                            labelCoordinates: self.labelCoordinates,
                            polygonCoordinates: polygonCoordinates)
        }
    }
    
    static func airSpacesByClass(from openAirString:String) -> AirSpacesByClassDictionary? {
        let lines = openAirString.components(separatedBy: .newlines)
        
        var airSpaces = [AirSpaceClass: [AirSpace]]()
        
        var currentAirspace: AirSpaceInProgress? = nil
        
        var state = ParserState()
        
        for line in lines {
            guard line.utf8.count > 1 else { continue }
            
            guard let firstWhiteSpace = line.rangeOfCharacter(from: .whitespaces) else { continue }
            
            let prefix = line[line.startIndex ..< firstWhiteSpace.lowerBound]
            let value = line[firstWhiteSpace.upperBound ..< line.endIndex]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            switch prefix {
            case "AC":
                currentAirspace.flatMap {
                    $0.validAirSpace.flatMap { asp in
                        var list = airSpaces[asp.class] ?? [AirSpace]()
                        list.append(asp)
                        airSpaces[asp.class] = list
                    }
                }
                
                state = ParserState()
                currentAirspace = AirSpaceInProgress()
                currentAirspace?.class = AirSpaceClass(rawValue: value)
            case "AN":
                currentAirspace?.name = value
            case "AL":
                currentAirspace?.floor = AirSpaceAltitude(value)
            case "AH":
                currentAirspace?.ceiling = AirSpaceAltitude(value)
            case "AT":
                guard let coord = coordinate(from: value) else { fatalError("got unparseable label coordinate: \(line)")  }
                if currentAirspace?.labelCoordinates == nil { currentAirspace?.labelCoordinates = [CLLocationCoordinate2D]() }
                currentAirspace?.labelCoordinates?.append(coord)
            case "V":
                if value.hasPrefix("X") {
                    guard let eqRange = value.range(of: "=") else { assertionFailure("malformed X"); return nil }
                    state.x = coordinate(from: value.suffix(from: eqRange.upperBound))
                } else if value.hasPrefix("D") {
                    guard let signRange = value.rangeOfCharacter(from: .plusMinus) else { fatalError("malformed direction line: \(line)") }
                    let sign = value[signRange.lowerBound ..< signRange.upperBound]
                    state.clockwise = (sign == "+")
                } else {
                    continue
                }
            case "DC":
                //*    DC radius; draw a circle (center taken from the previous V X=...  record, radius in nm
                guard let center = state.x else { fatalError("got circle but got no center: \(line)") }
                guard let radiusInNM = Double(value) else { fatalError("got circle but got no radius: \(line)") }
                let radius = Measurement(value: radiusInNM, unit: UnitLength.nauticalMiles).converted(to: .meters)
                currentAirspace?.polygonCoordinates.append(contentsOf: polygonArc(around: center, radius: radius.value, from: 0.0, to: 0.0, clockwise: true))
            case "DP":
                //*    DP coordinate; add polygon pointC
                guard let coord = coordinate(from: value) else { fatalError("got unparseable polygon point: \(line)")  }
                currentAirspace?.polygonCoordinates.append(coord)
            case "DA":
                //*    DA radius, angleStart, angleEnd; add an arc, angles in degrees, radius in nm (set center using V X=...)
                guard let center = state.x else { fatalError("got an arc but got no center: \(line)") }
                let numbers = value.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.compactMap(Double.init)
                guard numbers.count == 3 else { fatalError("Need 3 parameters for DA arc but got \(numbers.count): \(line)") }
                let radius = Measurement(value: numbers[0], unit: UnitLength.nauticalMiles).converted(to: .meters)
                let coords = polygonArc(around: center, radius: radius.value, from: numbers[1], to: numbers[2], clockwise: state.clockwise)
                currentAirspace?.polygonCoordinates.append(contentsOf: coords)
            case "DB":
                //*    DB coordinate1, coordinate2; add an arc, from coordinate1 to coordinate2 (set center using V X=...)
                guard let center = state.x else { fatalError("got an arc but got no center: \(line)") }
                let fromToCoords = value.components(separatedBy: ",").compactMap(coordinate)
                guard fromToCoords.count == 2 else { fatalError("Need 2 points for DB arc but got \(fromToCoords.count): \(line)") }
                let from = fromToCoords.first!
                let to = fromToCoords.last!
                let dist1 = center.distance(from: from)
                let dist2 = center.distance(from: to)
                let radius = 0.5 * (dist1 + dist2)
                let fromDeg = center.bearing(to: from)
                let toDeg = center.bearing(to: to)
                let coords = polygonArc(around: center, radius: radius, from: fromDeg, to: toDeg, clockwise: state.clockwise)
                currentAirspace?.polygonCoordinates.append(contentsOf: coords)
            default:
                continue
            }
            
        }
        
        currentAirspace.flatMap {
            $0.validAirSpace.flatMap { asp in
                var list = airSpaces[asp.class] ?? [AirSpace]()
                list.append(asp)
                airSpaces[asp.class] = list
            }
        }
        
        return airSpaces
    }
        
    static func airSpaces(from openAirString:String) -> [AirSpace]? {
        guard let airspaces = self.airSpacesByClass(from: openAirString) else { return nil }
        let flatAirSpaces = airspaces.reduce([AirSpace]()) { (res, tuple) -> [AirSpace] in
            return res + tuple.value
        }
        return flatAirSpaces
    }
    
    static func airSpacesByClass(withContentsOf url: URL) ->AirSpacesByClassDictionary? {
        var openAirString = ""
        do {
            openAirString = try String(contentsOf: url, encoding: .ascii)
        }
        catch _ {
            return nil
        }
        
        return self.airSpacesByClass(from: openAirString)
    }
        
    static func airSpaces(withContentsOf url: URL) -> [AirSpace]? {
        var openAirString = ""
        do {
            openAirString = try String(contentsOf: url, encoding: .ascii)
        }
        catch _ {
            return nil
        }
        
        return self.airSpaces(from: openAirString)
    }
    
    private static func coordinate<S: StringProtocol>(from string: S) -> CLLocationCoordinate2D? {
        let scanner = Scanner(string: string.uppercased())
        guard let latString = scanner.scanUpToCharacters(from: .northSouth) else { fatalError("could not find N/S in coordinate string") }
        
        let latComponents = latString.components(separatedBy: ":")
        
        var latitude = latComponents.degree
        guard latitude <= 90.0 else { fatalError("latitude \(latitude) for \"\(string)\"; \(dump(latComponents))") }
        
        guard let latHemisphere = scanner.scanCharacters(from: .northSouth) else { fatalError("could not find N/S hemisphere")}
        
        if latHemisphere == "S" { latitude = -1.0 * latitude }
        
        guard let lngString = scanner.scanUpToCharacters(from: .eastWest) else { fatalError("could not find EW in coordinate string") }
        
        guard let lngHemisphere = scanner.scanCharacters(from: .eastWest) else { fatalError("could not find E/W hemisphere")}
        
        let lngComponents = lngString.components(separatedBy: ":")
        
        var longitude = lngComponents.degree
        guard longitude <= 180.0 else { fatalError("longitude \(longitude) for \"\(string)\"; \(dump(lngComponents))") }
        
        if lngHemisphere == "W" { longitude = -1.0 * longitude }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    private static func polygonArc(around center: CLLocationCoordinate2D, radius: CLLocationDistance, from: CLLocationDegrees, to: CLLocationDegrees, clockwise: Bool) -> [CLLocationCoordinate2D] {
        let resolution = 5.0
        
        let sign = clockwise ? 1.0 : -1.0
        
        let start = from
        
        var end = (to == from) ? from+360.0 : to
        
        if (clockwise && to < from ) {
            end += 360.0
        }
        
        if (!clockwise && to > from) {
            end -= 360.0
        }
        
        let range = fabs(end - start)
        let count = ceil(range/resolution)
        let step = sign*range/count
        
        let coordinates = stride(from: start, through: end, by: step)
            .map { degree in center.coordinate(at: radius, direction: degree) }
        
        return coordinates
    }
}

extension AirSpaceAltitude {
    var geoJsonAltitude: Int {
        switch self {
        case .surface:
            return 0
        case .fl(let level):
            let flMeasure = Measurement(value: 100.0*Double(level), unit: UnitLength.feet).converted(to: .meters)
            let intMeters = Int(flMeasure.value.rounded())
            return intMeters
        case .agl(let alt):
            let intAGL = Int(alt.converted(to: .meters).value)
            return intAGL
        case .msl(let alt):
            let intMSL = Int(alt.converted(to: .meters).value)
            return intMSL
        }
    }
}

extension AirSpace: GeoJsonEncodable {
    public var geoJsonString: String? {
        let coordinatesArray: [[Double]] = (self.polygonCoordinates+[self.polygonCoordinates[0]]).reversed().map { [$0.longitude, $0.latitude] }
        
        let dict: NSDictionary = [
            "type": "Feature",
            "properties": [
                "name": self.name as NSString,
                "type": self.class.rawValue as NSString,
                "floor": self.floor.geoJsonAltitude,
                "ceiling": self.ceiling.geoJsonAltitude,
            ] as NSDictionary,
            "geometry": [
                "type": "Polygon" as NSString,
                "coordinates": [ coordinatesArray as NSArray ] as NSArray,
            ] as NSDictionary
        ]
        
        guard JSONSerialization.isValidJSONObject(dict) else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else { return nil }
        return String(data: data, encoding: .utf8)
    
    }
}

