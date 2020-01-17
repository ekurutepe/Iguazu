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
  public let task: IGCTask?

  let fixLines: [String]

  private let _fixes = IGCDataBox<[IGCFix]> { (igcData) -> [IGCFix] in
    return igcData.fixLines.concurrentMap { (line) -> IGCFix in
      return IGCFix(with: line, midnight: igcData.header.flightDate, extensions: igcData.extensions) }
  }
  
  public var fixes: [IGCFix] {
    return _fixes.value(input: self)
  }

  public func fix(for date: Date) -> DirectionedFix? {
    var offset: Int?
    let f = fixes.enumerated().first { (idx, fix) -> Bool in
      let result = abs(fix.timestamp.timeIntervalSince(date)) < 1.0
      if result { offset = idx }
      return result
    }
    guard let ff = f?.1 else { return nil }
    
    if fixes.count - 1 > (offset ?? 0) {
      let direction = ff.coordinate.bearing(to: fixes[offset!+1].coordinate)
      return DirectionedFix(fix: ff, direction: direction)
    }
    
    return DirectionedFix(fix: ff, direction: 0.0)
    
  }
  
  public var takeOffDate: Date? {
    // Do not use self.fixes here to avoid parsing the whole file
    guard let line = self.fixLines.first else { return nil }

    return IGCFix(with: line, midnight: self.header.flightDate).timestamp
  }

  public var landingDate: Date? {
    // Do not use self.fixes here to avoid parsing the whole file
    guard let line = self.fixLines.last else { return nil }

    return IGCFix(with: line, midnight: self.header.flightDate).timestamp
  }

  public lazy var takeOffLocation: CLLocation? = {
    // Do not use self.fixes here to avoid parsing the whole file
    guard let line = self.fixLines.first else { return nil }

    let fix = IGCFix(with: line, midnight: self.header.flightDate)
    return fix.clLocation
  }()

  public lazy var landingLocation: CLLocation? = {
    // Do not use self.fixes here to avoid parsing the whole file
    guard let line = self.fixLines.last else { return nil }

    let fix = IGCFix(with: line, midnight: self.header.flightDate)

    return fix.clLocation
  }()

  public let extensions: [IGCExtension]?
  
  public var locations: [CLLocation] {
    return fixes.concurrentMap { $0.clLocation }
  }

  public var polyline: MKPolyline {
    let coordinates = fixes.concurrentMap { $0.clLocation.coordinate }

    return MKPolyline(coordinates: coordinates, count: coordinates.count)
  }

  /// The simplified path expressed as a CLLocationCoordinate2D array in 2D
  public lazy var simplifiedCoordinates: [CLLocationCoordinate2D] = {
    let coordinates = fixes.concurrentMap { $0.clLocation.coordinate }
    let simplified = SwiftSimplify.simplify(coordinates, tolerance: 0.0001, highQuality: true)
    return simplified
  }()

  /// The simplified path expressed as a CLLocation array including altitudes in 3D
  public lazy var simplifiedLocations: [CLLocation] = {
    let locations = self.locations
    let simplified = SwiftSimplify.simplify(locations, tolerance: 0.0001, highQuality: true)
    return simplified
  }()

  public lazy var simplifiedPolyline: MKPolyline = {
    let simplified = simplifiedCoordinates
    return MKPolyline(coordinates: simplified, count: simplified.count)
  }()

  public lazy var northEastCorner: CLLocationCoordinate2D = {
    let lats = locations.map { $0.coordinate.latitude }
    let lons = locations.map { $0.coordinate.longitude }
    return CLLocationCoordinate2D(latitude: lats.max() ?? 0.0, longitude: lons.max() ?? 0.0)
  }()

  public lazy var southWestCorner: CLLocationCoordinate2D = {
    let lats = locations.map { $0.coordinate.latitude }
    let lons = locations.map { $0.coordinate.longitude }
    return CLLocationCoordinate2D(latitude: lats.min() ?? 0.0, longitude: lons.min() ?? 0.0)
  }()

  public lazy var altitudes: [Int] = {
    return fixes.map { $0.altimeterAltitude }
  }()

  public lazy var groundSpeeds: [Double] = {
    return fixes.enumerated().map { (offset, element) -> Double in
      if offset == 0 { return 0.0 }
      let prevFix = fixes[offset - 1]
      let deltaX = element.clLocation.distance(from: prevFix.clLocation)
      let deltaT = element.timestamp.timeIntervalSince(prevFix.timestamp)
      return deltaX / deltaT
    }
  }()

  public lazy var varioValues: [Double] = {
    return fixes.enumerated().map { (offset, element) -> Double in
      if offset == 0 { return 0.0 }
      let prevFix = fixes[offset - 1]
      let deltaX = Double(element.altimeterAltitude - prevFix.altimeterAltitude)
      let deltaT = element.timestamp.timeIntervalSince(prevFix.timestamp)
      return deltaX / deltaT
    }
  }()

  public lazy var totalEnergyValues: [Double] = {
    return fixes.enumerated().map { (offset, element) -> Double in
      if offset == 0 { return 0.0 }
      if offset == 1 { return 0.0 }
      if let vat = element.extensions[.totalEnergy] {
        return Double(vat)/100.0
      }
      let prevFix = fixes[offset - 1]
      let prevPrevFix = fixes[offset - 2]
      let deltaH = Double(element.altimeterAltitude - prevFix.altimeterAltitude)
      let deltaX = element.clLocation.distance(from: prevFix.clLocation)
      let deltaT = element.timestamp.timeIntervalSince(prevFix.timestamp)
      let currentV: Double
      if let airspeed = element.extensions[.trueAirspeed] {
        currentV = Double(airspeed)/360.0
        print(currentV)
      } else {
        currentV = deltaX / deltaT
      }
      let prevDeltaX = prevFix.clLocation.distance(from: prevPrevFix.clLocation)
      let prevDeltaT = prevFix.timestamp.timeIntervalSince(prevPrevFix.timestamp)
      let prevV: Double
      if let airspeed = prevFix.extensions[.trueAirspeed] {
        prevV = Double(airspeed)/360.0
      } else {
        prevV = prevDeltaX / prevDeltaT
      }
      let deltaVSq = currentV * currentV - prevV * prevV
      return deltaH + deltaVSq/19.62 // 2*g
    }
  }()

  /// Parses an IGCData instance from the string representation of an IGC
  /// File.
  ///
  /// - Parameter igcString: string read from the IGC file
  public init?(with igcString: String) {
    guard let header = IGCHeader(igcString: igcString) else { return nil }
    self.task = IGCTask(with: igcString)
    let lines = igcString.components(separatedBy: .newlines)

    guard lines.count > 0 else { return nil }

    let extensions = lines.filter { $0.hasPrefix("I") }
      .compactMap { IGCExtension.parseExtensions(line: $0) }.first

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
    self.task = nil
  }
}

fileprivate typealias IGCDataBox<T> = LazyBox<IGCData,T>

public struct DirectionedFix {
  let fix: IGCFix
  public let direction: CLLocationDegrees
  
  public var coordinate: CLLocationCoordinate2D { return fix.coordinate }
}
