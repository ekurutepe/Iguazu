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

    override func setUp() {
        super.setUp()
        do {

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

  func testOudieData() {
    let cpath = Bundle(for: IGCDataTests.self).path(forResource: "2020-06-01-XCM-09K-01", ofType: "igc")
    let oudieString = try! String(contentsOfFile: cpath!)

    guard let data = IGCData(with: oudieString) else { XCTFail("could not parse igc file"); return }

    XCTAssertGreaterThan(data.fixes.count, 0)
  }

    func testCorruptedData() {
        let cpath = Bundle(for: IGCDataTests.self).path(forResource: "corrupted", ofType: "igc")
        let corruptedIgcString = try! String(contentsOfFile: cpath!)

        guard let data = IGCData(with: corruptedIgcString) else { XCTFail("could not parse igc file"); return }

        XCTAssertGreaterThan(data.fixes.count, 0)
    }

    func testCorruptedData2() {
        let cpath = Bundle(for: IGCDataTests.self).url(forResource: "05DLGD01_rst", withExtension: "igc")!
        let corruptedIgcString = try! String(contentsOf: cpath, encoding: .ascii)

        guard let data = IGCData(with: corruptedIgcString) else { XCTFail("could not parse igc file"); return }

        XCTAssertGreaterThan(data.fixes.count, 0)
    }
}
