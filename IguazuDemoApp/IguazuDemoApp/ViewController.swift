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

class ViewController: UIViewController {

    @IBOutlet weak var mapview: MKMapView!
    
    var mapDelegate: AirSpaceMapDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadAirSpaces()
    }
    
    func loadAirSpaces() {
        
        let urlDE = Bundle.main.url(forResource: "DAeC_Germany_Week22_2016", withExtension: "txt")!
        
        let germany = AirSpace.airSpaces(withContentsOf: urlDE)
        
        let urlUS = Bundle.main.url(forResource: "allusa.v16.11-10.1", withExtension: "txt")!
        
        let usa = AirSpace.airSpaces(withContentsOf: urlUS)
        
        let allAirspaces = [germany ?? [], usa ?? []].joined().map { $0 }
        
        mapDelegate = AirSpaceMapDelegate(airspaces: allAirspaces)
        mapview.delegate = mapDelegate
        mapview.addOverlays(mapDelegate!.polygons)
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

        let flightPath = igcData.polyline
        mapview.addOverlays([flightPath])
        mapview.setVisibleMapRect(flightPath.boundingMapRect, animated: false)
        
    }
}


