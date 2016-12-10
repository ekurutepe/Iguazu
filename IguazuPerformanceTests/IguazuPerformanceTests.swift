//
//  IguazuPerformanceTests.swift
//  IguazuPerformanceTests
//
//  Created by Engin Kurutepe on 10/12/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import XCTest
@testable import Iguazu

class IguazuPerformanceTests: XCTestCase {
    
    var openAirString = ""
    
    override func setUp() {
        super.setUp()
        do {
            let url = Bundle(for: IguazuPerformanceTests.self).url(forResource: "DAeC_Germany_Week22_2016", withExtension: "txt")
            openAirString = try String(contentsOf: url!, encoding: .ascii)
        }
        catch {
            XCTFail("\(dump(error))")
        }
    }

    func testPerformanceExample() {
        self.measure {
            let _ = AirSpace.airSpaces(from: self.openAirString)
        }
    }
}
