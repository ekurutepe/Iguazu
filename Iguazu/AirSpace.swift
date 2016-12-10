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
}

public typealias Altitude = Measurement<UnitLength>

public typealias DegreeComponents = Array<String>

public extension Collection where Iterator.Element == String, Index == Int {
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
        
        let unit: UnitLength
        
        if impliedMSLString.contains("m") {
            unit = .meters
        } else {
            unit = .feet
        }
        
        if impliedMSLString.hasPrefix("fl") {
            self = .fl(flightLevel: value)
            return
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
    let `class`: AirSpaceClass
    let ceiling: AirSpaceAltitude
    let floor: AirSpaceAltitude
    let name: String
    let labelCoordinates: [CLLocationCoordinate2D]?
    let polygonCoordinates: [CLLocationCoordinate2D]
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
    
    public static func airSpaces(from openAirString:String) -> [AirSpace]? {
        let lines = openAirString.components(separatedBy: .newlines)
        
        var airSpaces = [AirSpace]()
        
        var currentAirspace: AirSpaceInProgress? = nil
        
        var state = ParserState()
        
        for line in lines {
            guard line.utf8.count > 1 else { continue }
            
            guard let firstWhiteSpace = line.rangeOfCharacter(from: .whitespaces) else { continue }
            
            let prefix = line.substring(to: firstWhiteSpace.lowerBound)
            let value = line.substring(from: firstWhiteSpace.upperBound)
            
            switch prefix {
            case "AC":
                currentAirspace.flatMap {
                    $0.validAirSpace.flatMap { asp in
                        airSpaces.append(asp) }
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
                    let eqRange = value.range(of: "=")!
                    state.x = coordinate(from: value.substring(from: eqRange.upperBound))
                } else if value.hasPrefix("D") {
                    guard let signRange = value.rangeOfCharacter(from: .plusMinus) else { fatalError("malformed direction line: \(line)") }
                    let sign = value.substring(with: signRange)
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
                let numbers = value.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.flatMap(Double.init)
                guard numbers.count == 3 else { fatalError("Need 3 parameters for DA arc but got \(numbers.count): \(line)") }
                let radius = Measurement(value: numbers[0], unit: UnitLength.nauticalMiles).converted(to: .meters)
                let coords = polygonArc(around: center, radius: radius.value, from: numbers[1], to: numbers[2], clockwise: state.clockwise)
                currentAirspace?.polygonCoordinates.append(contentsOf: coords)
            case "DB":
                //*    DB coordinate1, coordinate2; add an arc, from coordinate1 to coordinate2 (set center using V X=...)
                guard let center = state.x else { fatalError("got an arc but got no center: \(line)") }
                let fromToCoords = value.components(separatedBy: ",").flatMap(coordinate)
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
            //            dump($0)
            $0.validAirSpace.flatMap { asp in
                airSpaces.append(asp)
            }
        }
        
        return airSpaces
    }
    
    private static func coordinate(from string:String) -> CLLocationCoordinate2D? {
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
        
        var degressInArc = sign * (to - from)
        
        if to == from { degressInArc = 360.0 }
        
        if degressInArc < 0.0 { degressInArc += 360.0 }
        
        let numberOfPoints = Darwin.floor(degressInArc / resolution)
        
        let coordinates = (0 ... Int(numberOfPoints)).map { idx -> CLLocationCoordinate2D in
            let degrees = from + sign * Double(idx) * resolution
            return center.coordinate(at: radius, direction: degrees)
        }
        
        return coordinates
    }
}

