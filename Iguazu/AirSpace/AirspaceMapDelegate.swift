//
//  AirspaceMapDelegate.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 10/12/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import MapKit

public class AirspaceMapDelegate: NSObject, MKMapViewDelegate {
    private var _airspaceTable = [MKPolygon: Airspace]()
    
    public var airspaceTable: [MKPolygon: Airspace] {
        return _airspaceTable
    }
    
    public var polygons = [MKPolygon]()
    
    public required init(airspaces: [Airspace]) {
        super.init()
        polygons = airspaces.map {
            let coords = $0.polygonCoordinates
            let polygon = MKPolygon(coordinates: coords, count: coords.count)
            self._airspaceTable[polygon] = $0
            return polygon
        }
    }
    
    // MARK: MapView Delegate
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         if let polygon = overlay as? MKPolygon {
            let airSpace = self.airspaceTable[polygon]
            let renderer = MKPolygonRenderer(polygon: polygon)
            let airspaceColor = airSpace?.airspaceClass.color ?? .blue
            renderer.strokeColor = airspaceColor.withAlphaComponent(0.7)
            renderer.fillColor = airspaceColor.withAlphaComponent(0.1)
            renderer.lineWidth = 1.0
            
            return renderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}

public extension AirspaceClass {
#if os(OSX)
    var color: NSColor {
        switch self {
        case .Danger:
            return .black
        case .CTR, .GliderProhibited, .Prohibited, .Restricted:
            return .red
        case .Delta:
            return .green
        case .Bravo, .Charlie, .RadioMandatoryZone:
            return NSColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)
        case .TransponderMandatoryZone:
            return .gray
        default:
            return .purple
        }
    }
#elseif os(iOS)
    var color: UIColor {
        switch self {
        case .Danger:
            return .black
        case .CTR, .GliderProhibited, .Prohibited, .Restricted:
            return .red
        case .Delta:
            return .green
        case .Bravo, .Charlie, .RadioMandatoryZone:
            return UIColor(red: 0.0, green: 0.6, blue: 1.0, alpha: 1.0)
        case .TransponderMandatoryZone:
            return .gray
        default:
            return .purple
        }
    }
#endif
}

