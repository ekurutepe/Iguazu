//
//  IGCRecord.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 12/06/16.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import Foundation
import CoreLocation

protocol IGCRecord {
    var timestamp: Date { get }
}

/// <#Description#>
struct IGCFix: IGCRecord {
    let timestamp: Date
    let coordinate: CLLocationCoordinate2D
    let altimeterAltitude: Int
    let gpsAltitude: Int
    let fixAccuracy: Int
    
    static func parseFix(with line:String, midnight: Date) -> IGCFix? {
        guard let prefix = line.extractString(from: 0, length: 1), prefix == "B" else { return nil }
        
        guard let timeComponents = line.extractTime(from: 1) else { return nil }
        
        let timestamp = Calendar.current.date(byAdding: timeComponents, to: midnight)
        
        print(timestamp)
        
        guard let lat = line.extractLatitude(from: 7) else { return nil }
        guard let lng = line.extractLongitude(from: 15) else { return nil }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        
        print(coordinate)
        
        return nil 
//        return IGCFix(timestamp: timestamp,
//            coordinate: <#T##CLLocationCoordinate2D#>,
//            altimeterAltitude: <#T##Int#>,
//            gpsAltitude: <#T##Int#>,
//            fixAccuracy: <#T##Int#>)
    }
}

// TODO: create real event type
enum IGCEventType {
    case dummy
}

///
struct IGCEvent: IGCRecord {
    let timestamp: Date
    let event: IGCEventType
}
