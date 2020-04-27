//
//  IGCDataTests.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 16/06/16.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import XCTest
@testable import Iguazu

class IGCDataTests: XCTestCase {

    var igcString = ""
    var corruptedIgcString = ""

    override func setUp() {
        super.setUp()
        do {
            let path = Bundle(for: IGCDataTests.self).path(forResource: "lx7007", ofType: "igc")
            igcString = try String(contentsOfFile: path!)
            let cpath = Bundle(for: IGCDataTests.self).path(forResource: "corrupted", ofType: "igc")
            corruptedIgcString = try String(contentsOfFile: cpath!)
        }
        catch _ {
            XCTFail()
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHeader() {
        guard let data = IGCData(with: igcString) else { XCTFail("could not parse igc file"); return }
        let header = data.header

        XCTAssertGreaterThan(header.headerFields.count, 0)
    }

    func testExtensions() {
        guard let data = IGCData(with: igcString) else { XCTFail("could not parse igc file"); return }

        XCTAssertNotNil(data.extensions)

        XCTAssertEqual(data.extensions?.count, 2)
    }

    func testRecords() {
        guard let data = IGCData(with: igcString) else { XCTFail("could not parse igc file"); return }

        XCTAssertGreaterThan(data.fixes.count, 0)
    }

    func testCorruptedData() {
        guard let data = IGCData(with: corruptedIgcString) else { XCTFail("could not parse igc file"); return }

        XCTAssertGreaterThan(data.fixes.count, 0)
    }
}
