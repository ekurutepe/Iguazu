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
        var igcString = ""

        do {
            let path = Bundle.main.path(forResource: "lx7007", ofType: "igc")
            igcString = try String(contentsOfFile: path!)
        }
        catch _ {
            fatalError("could not open the IGC file")
        }

        let igcData = IGCData(with: igcString)!

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
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue.withAlphaComponent(0.7)
        renderer.lineWidth = 3.0
        return renderer
    }

}
