//
//  IGCTask.swift
//  Pods
//
//  Created by Engin Kurutepe on 17.01.20.
//

import Foundation
import CoreLocation

public struct IGCTask: CustomStringConvertible {
  public let title: String
  public let declarationDate: Date
  public let waypointCount: Int
  internal(set) public var waypoints: [IGCWaypoint] = []
    
  public var description: String {
    return "Task: \(title)"
  }
}

private let DateOffset = 1
private let TimeOffset = 7
private let TurnpointCountOffset = 23
private let TitleOffset = 25

public extension IGCTask {
  public init?(with igcString: String) {
    
    let lines = igcString.components(separatedBy: .newlines)
      .filter({ (line) -> Bool in
        return line.hasPrefix("C")
      })

    guard let line = lines.first else {
      return nil
    }
    
    guard
      let prefix = line.extractString(from: 0, length: 1), prefix == "C"
    else {
      return nil
    }
    
    guard
      let dateString = line.extractString(from: DateOffset, length: 6),
      let date = Date.parse(headerDateString: dateString),
      let timeString = line.extractString(from: TimeOffset, length: 6),
      let time = Date.parse(fixTimeString: timeString, on: date)
    else {
      return nil
    }
    
    declarationDate = time
    
    guard
      let countString = line.extractString(from: TurnpointCountOffset, length: 2),
      let count = Int(countString)
    else {
      return nil
    }
    
    waypointCount = count
    
    title = line.extractString(from: TitleOffset, length: 0) ?? ""
    
    let totalLines = waypointCount + 5
    guard lines.count == totalLines else { return nil }
    
    let wpLines = lines.dropFirst()
    
    waypoints = wpLines.map {
      return IGCWaypoint(with: $0)
    }
  }
}
