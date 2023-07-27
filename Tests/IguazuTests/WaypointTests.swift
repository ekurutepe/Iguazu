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
    override func setUp() {
        super.setUp()

    }

    func testFileParsing() {
        let url = Bundle(for: AirSpaceTests.self).url(forResource: "klppnck6-utf8", withExtension: "cup")!
        guard
            let file = CUPFile(name: "test", fileURL: url)
        else {
            XCTFail("could not parse waypoints file")
            return
        }
        let waypoints = file.points
        XCTAssertTrue(waypoints.count > 0)
        let lusse = waypoints.first!
        XCTAssertEqual(lusse.title, "001 AP1 Klippeneck")
        XCTAssertEqual(lusse.code, "AP1")
    }


    func testProblematicEncodingParsing() {
        let url = Bundle(for: AirSpaceTests.self).url(forResource: "klppnck6", withExtension: "cup")!
        guard
            let file = CUPFile(name: "test", fileURL: url)
        else {
            XCTFail("could not parse waypoints file")
            return
        }
        let waypoints = file.points
        XCTAssertTrue(waypoints.count > 0)
        let lusse = waypoints.first!
        XCTAssertEqual(lusse.title, "001 AP1 Klippeneck")
        XCTAssertEqual(lusse.code, "AP1")
    }

    func testParsingWithCommas() {
        let commasUrl = Bundle(for: AirSpaceTests.self).url(forResource: "Commas", withExtension: "cup")!
        let cupString = try! String(contentsOf: commasUrl)

        let pois = cupString.components(separatedBy: .newlines).compactMap { (line) -> PointOfInterest? in
            let p = CUPParser.pointOfInterest(from: line, sourceIdentifier: "source")
            return p
        }

        XCTAssertEqual(pois.count, 3)
    }
    
    

}


