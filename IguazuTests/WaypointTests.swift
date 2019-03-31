//
//  WaypointTest.swift
//  IguazuTests
//
//  Created by Engin Kurutepe on 31.03.19.
//  Copyright © 2019 Fifteen Jugglers Software. All rights reserved.
//

import XCTest
@testable import Iguazu

class WaypointTests : XCTestCase {
    var cupString = ""
    
    override func setUp() {
        super.setUp()
        do {
            let url = Bundle(for: AirSpaceTests.self).url(forResource: "WP2019_Luesse", withExtension: "cup")
            cupString = try String(contentsOf: url!, encoding: .ascii)
        }
        catch {
            XCTFail("\(dump(error))")
        }
    }
    
    func testFileParsing() {
        let waypoints = Waypoint.waypoints(from: cupString)
        XCTAssertTrue(waypoints.count > 0)
        let lusse = waypoints.first!
        XCTAssertEqual(lusse.title, "001SPLuesse")
        XCTAssertEqual(lusse.latitude, 52.14416666666666)
        XCTAssertEqual(lusse.longitude, 12.668333333333333)
        XCTAssertEqual(lusse.elevation, 66.0)
    }
    
    

}


