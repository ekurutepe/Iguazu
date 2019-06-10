//
//  AirportTests.swift
//  IguazuTests
//
//  Created by Engin Kurutepe on 10.06.19.
//  Copyright © 2019 Fifteen Jugglers Software. All rights reserved.
//

import XCTest
@testable import Iguazu

class AirportTests : XCTestCase {
    var cupString = ""

    override func setUp() {
        super.setUp()
        do {
            let url = Bundle(for: AirSpaceTests.self).url(forResource: "airports", withExtension: "cup")
            cupString = try String(contentsOf: url!, encoding: .ascii)
        }
        catch {
            XCTFail("\(dump(error))")
        }
    }

    func testFileParsing() {
        let waypoints = Airport.airports(from: cupString)
        XCTAssertTrue(waypoints.count > 0)
        let ap = waypoints.first!
        XCTAssertEqual(ap.title, "AACHEN-MERZBRUECK")
        XCTAssertEqual(ap.code, "EDKA")
        XCTAssertEqual(ap.country, "DE")
        XCTAssertEqual(ap.frequency, "122.880")
        XCTAssertEqual(ap.elevation.value, 190)
        XCTAssertEqual(ap.direction, 77)
        XCTAssertEqual(ap.length?.value, 520)
    }



}



