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
    var url: URL!

    override func setUp() {
        super.setUp()
        url = Bundle(for: AirSpaceTests.self).url(forResource: "airports", withExtension: "cup")
    }

    func testFileParsing() {
        guard let waypoints = CUPFile(name: "test", fileURL: url)?.airports else {
            XCTFail("could not parse cup file")
            return
        }
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



