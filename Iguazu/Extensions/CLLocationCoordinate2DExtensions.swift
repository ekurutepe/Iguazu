//
//  CLLocationCoordinate2DExtensions.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 10/12/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import CoreLocation

public extension CLLocationCoordinate2D {
    static let zero = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    static let EarthRadius = 6_378_137.0

    private func DegreesToRadians(_ degrees: Double) -> Double { return degrees * .pi / 180.0 }
    private func RadiansToDegrees(_ radians: Double) -> CLLocationDegrees { return radians * 180.0 / .pi }
    
    // calculations taken from http://gis.stackexchange.com/questions/75528/length-of-a-degree-where-do-the-terms-in-this-formula-come-from
    var metersPerLatitudeDegree: CLLocationDistance {
        let m1 = 111132.92;     // latitude calculation term 1
        let m2 = -559.82;       // latitude calculation term 2
        let m3 = 1.175;         // latitude calculation term 3
        let m4 = -0.0023;       // latitude calculation term 4
        let latitudeInRad = DegreesToRadians(latitude)
        return m1 + m2 * cos(2 * latitudeInRad) + m3 * cos(4 * latitudeInRad) + m4 * cos(6 * latitudeInRad)
    }

    var metersPerLongitudeDegree: CLLocationDistance {
        let p1 = 111412.84     // longitude calculation term 1
        let p2 = -93.5         // longitude calculation term 2
        let p3 = 0.118         // longitude calculation term 3
        let latitudeInRad = DegreesToRadians(latitude)
        return p1 * cos(latitudeInRad) + p2 * cos(3 * latitudeInRad) + p3 * cos(5 * latitudeInRad)
    }
    
    func distance(from coord: CLLocationCoordinate2D) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let loc2 = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        
        return loc1.distance(from: loc2)
    }

    func radians(to coord:CLLocationCoordinate2D) -> Double {
        let lat1 = DegreesToRadians(self.latitude);
        let lon1 = DegreesToRadians(self.longitude);

        let lat2 = DegreesToRadians(coord.latitude);
        let lon2 = DegreesToRadians(coord.longitude);

        let dLon = lon2 - lon1;

        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        return atan2(y, x);
    }
    
    func bearing(to coord:CLLocationCoordinate2D) -> CLLocationDegrees {
        let lat1 = DegreesToRadians(self.latitude);
        let lon1 = DegreesToRadians(self.longitude);
        
        let lat2 = DegreesToRadians(coord.latitude);
        let lon2 = DegreesToRadians(coord.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        let degrees = RadiansToDegrees(radiansBearing)
        return degrees > 0.0 ? degrees : degrees + 360.0;
    }
    
    func coordinate(at distance: CLLocationDistance, direction: CLLocationDirection) -> CLLocationCoordinate2D {
        let latInRad = DegreesToRadians(latitude)
        let lonInRad = DegreesToRadians(longitude)
        let R = CLLocationCoordinate2D.EarthRadius
        let angularDistance = distance/R
        let bearingInRad = DegreesToRadians(direction)
        
        let lat2InRad = asin( sin(latInRad)*cos(angularDistance) + cos(latInRad)*sin(angularDistance)*cos(bearingInRad) )
        let lon2InRad = lonInRad + atan2(sin(bearingInRad)*sin(angularDistance)*cos(latInRad), cos(angularDistance)-sin(latInRad)*sin(lat2InRad));
        
        let coord = CLLocationCoordinate2D(latitude: RadiansToDegrees(lat2InRad), longitude: RadiansToDegrees(lon2InRad))
        
        return coord
    }
}
