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
    public let header: IGCHeader

    private let fixLines: [String]
    public lazy var fixes: [IGCFix] = {
        self.fixLines.map { IGCFix.parseFix(with: $0, midnight: self.header.flightDate) }
    }()

    public lazy var takeOffLocation: CLLocation? = {
        guard let line = self.fixLines.first else { return nil }

        let fix = IGCFix.parseFix(with: line, midnight: self.header.flightDate)

        return fix.clLocation
    }()

    public lazy var landingLocation: CLLocation? = {
        guard let line = self.fixLines.last else { return nil }

        let fix = IGCFix.parseFix(with: line, midnight: self.header.flightDate)

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
}

public extension IGCData {
    init?(with igcString: String) {
        guard let header = IGCHeader(igcString: igcString) else { return nil }

        let lines = igcString.components(separatedBy: .newlines)

        let extensions = lines.filter { $0.hasPrefix("I") }
            .flatMap { IGCExtension.parseExtensions(line: $0) }.first

        let fixes = lines.filter { $0.hasPrefix("B") }

        self.header = header
        self.fixLines = fixes
        self.extensions = extensions
    }
}
