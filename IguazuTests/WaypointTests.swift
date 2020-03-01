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
    var url: URL!

    override func setUp() {
        super.setUp()
        url = Bundle(for: AirSpaceTests.self).url(forResource: "WP2019_Luesse", withExtension: "cup")
    }

    func testFileParsing() {
        guard let waypoints = CUPFile(name: "test", fileURL: url)?.points else {
            XCTFail("could not parse waypoints file")
            return
        }
        XCTAssertTrue(waypoints.count > 0)
        let lusse = waypoints.first!
        XCTAssertEqual(lusse.title, "001SPLuesse")
        XCTAssertEqual(lusse.code, "001")
        XCTAssertEqual(lusse.latitude.value, 52.14416666666666)
        XCTAssertEqual(lusse.longitude.value, 12.668333333333333)
        XCTAssertEqual(lusse.elevation.value, 66.0)
    }
    
    

}


