//
//  IGCParser.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 12/06/16.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

/// Represents an IGC file.
public struct IGCData {

    // must be declared as var due to lazy property accessors in IGCHeader
    // pending https://github.com/apple/swift-evolution/blob/master/proposals/0030-property-behavior-decls.md
    public var header: IGCHeader

    let fixLines: [String]
    
    public lazy var fixes: [IGCFix] = {
        self.fixLines.map { IGCFix(with: $0, midnight: self.header.flightDate) }
    }()

    public lazy var takeOffLocation: CLLocation? = {
        guard let line = self.fixLines.first else { return nil }

        let fix = IGCFix(with: line, midnight: self.header.flightDate)

        return fix.clLocation
    }()

    public lazy var landingLocation: CLLocation? = {
        guard let line = self.fixLines.last else { return nil }

        let fix = IGCFix(with: line, midnight: self.header.flightDate)

        return fix.clLocation
    }()
    
    public let extensions: [IGCExtension]?

    public lazy var locations: [CLLocation] = {
        self.fixes.map { $0.clLocation }
    }()

    public lazy var polyline: MKPolyline = {
        let coordinates = self.locations.map { $0.coordinate }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }()


    /// Parses an IGCData instance from the string representation of an IGC
    /// File.
    ///
    /// - Parameter igcString: string read from the IGC file
    public init?(with igcString: String) {
        guard let header = IGCHeader(igcString: igcString) else { return nil }

        let lines = igcString.components(separatedBy: .newlines)
        
        guard lines.count > 0 else { return nil }

        let extensions = lines.filter { $0.hasPrefix("I") }
            .flatMap { IGCExtension.parseExtensions(line: $0) }.first

        let fixes = lines.filter { $0.hasPrefix("B") }

        self.header = header
        self.fixLines = fixes
        self.extensions = extensions
    }
    
    /// Configures an IGCData instance using the recorded flight data.
    ///
    /// - Parameters:
    ///   - locations: an array of CLLocation instances. The timestamps of these 
    ///         locations are the timestamps in the resulting IGC file
    ///   - altitudes:  an optional array of altimeter altitude values. When present
    ///         the identical number of elements is expected as in the `locations`
    ///         array.
    ///   - pic: the name of Pilot in Command
    ///   - crew: the name of second crew member if present on a double seater
    ///   - gliderType: Type of the glider, e.g 'ASK-21'
    ///   - gliderRegistration: the official registration number of the glider
    ///         e.g 'D-0680'
    public init?(with locations: [CLLocation], altitudes: [Double]?, pic: String, crew: String?, gliderType: String, gliderRegistration: String) {
        precondition(locations.count > 0)
        let _altitudes: [Double]
        if let alts = altitudes {
            _altitudes = alts
            precondition(locations.count == _altitudes.count)
        } else {
            _altitudes = locations.map { _ in  0.0 }
        }
        
        let date = locations.first!.timestamp.midnightInUTC
        self.header = IGCHeader(with: date, pic: pic, crew: crew, gliderType: gliderType, gliderRegistration: gliderRegistration)
        self.fixLines = zip(locations, _altitudes)
            .map {
                IGCFix(with: $0, altimeterAltitude: $1)
            }
            .map {
                $0.bLine
            }
        self.extensions = nil
            
    }
}
