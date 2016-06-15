//
//  IGCHeaderTests.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 15/06/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import XCTest
@testable import Iguazu

class IGCHeaderTests: XCTestCase {
    
    let dateHeaderString = "HFDTE250809"
    let accuracyHeaderString = "HFFXA100"
    let pilotHeaderString = "HFPLTPILOT:Ian Forster-Lewis"
    let pilotHeaderLongString = "HFPLTPILOTINCHARGE:Ian Forster-Lewis"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDateHeader() {
        if let dateHeader = IGCHeaderField.parseHLine(hLine: dateHeaderString) {
            switch dateHeader {
            case .date(let d):
                print("date \(d)")
                XCTAssertTrue(d.timeIntervalSinceReferenceDate == 272851200.0)
            default:
                XCTFail("expecting a date header but got something else")
            }
        } else {
            XCTFail("failed to parse a non-nil header from \(dateHeaderString)")
        }
        return
    }
    
    func testAccuracyHeader() {
        if let accuracyHeader = IGCHeaderField.parseHLine(hLine: accuracyHeaderString) {
            switch accuracyHeader {
            case .accuracy(let acc):
                print("accuracy \(acc)")
                XCTAssertEqual(acc, 100)
            default:
                XCTFail("expecting a accuracy header but got something else")
            }
        } else {
            XCTFail("failed to parse a non-nil header from \(accuracyHeaderString)")
        }
        return
    }
    
    func testPilotHeader() {
        if let pilotHeader = IGCHeaderField.parseHLine(hLine: pilotHeaderString) {
            switch pilotHeader {
            case .pilotInCharge(let pilotName):
                print("pilot name \(pilotName)")
                XCTAssertEqual(pilotName, "Ian Forster-Lewis")
            default:
                XCTFail("expecting a pilot header but got something else")
            }
        } else {
            XCTFail("failed to parse a non-nil header from \(pilotHeaderString)")
        }
        return
    }
    
    func testPilotLongHeader() {
        if let pilotHeader = IGCHeaderField.parseHLine(hLine: pilotHeaderLongString) {
            switch pilotHeader {
            case .pilotInCharge(let pilotName):
                print("pilot name \(pilotName)")
                XCTAssertEqual(pilotName, "Ian Forster-Lewis")
            default:
                XCTFail("expecting a pilot header but got something else")
            }
        } else {
            XCTFail("failed to parse a non-nil header from \(pilotHeaderLongString)")
        }
        return
    }
}
