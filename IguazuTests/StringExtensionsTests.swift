//
//  StringExtensionsTests.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 20/06/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import XCTest
@testable import Iguazu

class StringExtensionsTests: XCTestCase {

    let exampleString = "1234567890"
    let fixString = "B1101355206343N00006198WA0058700558027000"

    override func setUp() {
        super.setUp()

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStringExtract1() {
        let s123 = exampleString.extractString(from: 0, length: 3)

        XCTAssertEqual(s123, "123")
    }

    func testStringExtract2() {
        let s = exampleString.extractString(from: 0, length: 0)

        XCTAssertEqual(s, "")
    }

    func testStringExtract3() {
        let s = exampleString.extractString(from: 1, length: 2)

        XCTAssertEqual(s, "23")
    }

    func testDateExtract() {
        let components = fixString.extractTime(from: 1)

        XCTAssertEqual(components?.hour, 11)
        XCTAssertEqual(components?.minute, 1)
        XCTAssertEqual(components?.second, 35)
        XCTAssertEqual(components?.timeZone, TimeZone(abbreviation: "UTC"))
    }

    func testDateExtractFail() {
        let components = "B12qw34".extractTime(from: 1)

        XCTAssertNil(components)
    }

    func testLatitude() {
        guard let latitude = fixString.extractLatitude(from: 7) else {
            XCTFail("could not parse latitude"); return
        }

        XCTAssertEqualWithAccuracy(latitude, 52.105716, accuracy: 0.000001)
    }

    func testLongitude() {
        guard let longitude = fixString.extractLongitude(from: 15) else {
            XCTFail("could not parse longitude"); return
        }

        XCTAssertEqualWithAccuracy(longitude, -0.0103166, accuracy: 0.000001)
    }

    func testBarometricAltitude() {
        guard let altitude = fixString.extractAltitude(from: 25) else {
            XCTFail("could not parse barometric altitude"); return
        }

        XCTAssertEqual(altitude, 587)
    }

    func testGPSAltitude() {
        guard let altitude = fixString.extractAltitude(from: 30) else {
            XCTFail("could not parse GPS altitude"); return
        }

        XCTAssertEqual(altitude, 558)
    }

    func testAltitudeFail() {
        let altitude = "abc".extractAltitude(from: 0)

        XCTAssertNil(altitude)
    }

    func testAccuracy() {
        guard let accuracy = fixString.extractAccuracy(from: 35) else {
            XCTFail("could not parse Fix Accuracy"); return
        }

        XCTAssertEqual(accuracy, 27)
    }
}
