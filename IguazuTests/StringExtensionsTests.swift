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
    
    override func setUp() {
        super.setUp()
    
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testStringExtract1() {
        let s123 = exampleString.extract(from: 0, length: 3)
        
        XCTAssertEqual(s123, "123")
    }

    func testStringExtract2() {
        let s = exampleString.extract(from: 0, length: 0)
        
        XCTAssertEqual(s, "")
    }
    
    func testStringExtract3() {
        let s = exampleString.extract(from: 1, length: 2)
        
        XCTAssertEqual(s, "23")
    }

}
