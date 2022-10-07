//
//  IGCWaypoint.swift
//  Charts
//
//  Created by Engin Kurutepe on 17.01.20.
//

import Foundation
import CoreLocation

public struct IGCWaypoint: CustomStringConvertible {
  public let title: String
  public let coordinate: CLLocationCoordinate2D
    
  public var description: String {
    return "Waypoint: \(title) \(coordinate.latitude), \(coordinate.longitude)"
  }
}

private let LatitudeOffset = 1
private let LongitudeOffset = 9
private let TitleOffset = 18

public extension IGCWaypoint {
  init(with line: String) {
    guard
      let prefix = line.extractString(from: 0, length: 1), prefix == "C"
    else {
      fatalError("tried to initialize IGCWaypoint with a line that does NOT start with C: \(line)")
    }
    
    guard
      let lat = line.extractLatitude(from: LatitudeOffset),
      let lng = line.extractLongitude(from: LongitudeOffset)
    else {
      fatalError("could not extract lat lon from line: \(line)")
    }
    
    coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    title = line.extractString(from: TitleOffset, length: 0) ?? ""
  }
}
