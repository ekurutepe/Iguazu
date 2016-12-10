//
//  ViewController.swift
//  IguazuDemoApp
//
//  Created by Engin Kurutepe on 18/08/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import UIKit
import Iguazu
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapview: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadAirSpaces()
    }
    
    var airspaceTable = [MKPolygon: AirSpace]()
    
    func loadAirSpaces() {
        var openAirString = ""
        
        do {
            let url = Bundle.main.url(forResource: "DAeC_Germany_Week22_2016", withExtension: "txt")!
            openAirString = try String(contentsOf: url, encoding: .ascii)
        }
        catch _ {
            fatalError("could not open the OpenAir file")
        }
        
        let airspaces = AirSpace.airSpaces(from: openAirString)
        
        mapview.delegate = self
        
        airspaces?.forEach {
            let coords = $0.polygonCoordinates
            let polygon = MKPolygon(coordinates: coords, count: coords.count)
            self.airspaceTable[polygon] = $0
            self.mapview.add(polygon)
        }
    }
    
    func loadIGCFile() {
        var igcString = ""

        do {
            let path = Bundle.main.path(forResource: "lx7007", ofType: "igc")
            igcString = try String(contentsOfFile: path!)
        }
        catch _ {
            fatalError("could not open the IGC file")
        }

        var igcData = IGCData(with: igcString)!

        print("Loaded IGC File")
        print("Headers:")
        print("\(igcData.header)")
        print("Extensions:")
        print("\(igcData.extensions)")
        print("Fixes:")
        print("\(igcData.fixes)")

        mapview.delegate = self
        let flightPath = igcData.polyline
        mapview.addOverlays([flightPath])
        mapview.setVisibleMapRect(flightPath.boundingMapRect, animated: false)
        
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue.withAlphaComponent(0.7)
            renderer.lineWidth = 3.0
            return renderer
        } else if let polygon = overlay as? MKPolygon {
            let airSpace = self.airspaceTable[polygon]
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = (airSpace?.class.color ?? .blue).withAlphaComponent(0.7)
            renderer.lineWidth = 1.0
            return renderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }

}

extension AirSpaceClass {
    var color: UIColor {
        switch self {
        case .CTR, .Danger, .GliderProhibited, .Prohibited, .Restricted:
            return .red
        default:
            return .blue
        }
    }
}
