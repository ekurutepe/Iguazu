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
