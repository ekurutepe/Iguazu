//
//  IGCParserTests.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 16/06/16.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import XCTest
@testable import Iguazu

class IGCParserTests: XCTestCase {

    var igcString = ""
    
    override func setUp() {
        super.setUp()
        do {
            let path = Bundle(for: IGCParserTests.self).pathForResource("lx7007", ofType: "igc")
            igcString = try String.init(contentsOfFile: path!)
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
        let header = IGCHeader(igcString: igcString)
        
        XCTAssertNotNil(header)
        guard let headerFields = header?.headerFields else { return }
        XCTAssertGreaterThan(headerFields.count, 0)
    }
    
}
