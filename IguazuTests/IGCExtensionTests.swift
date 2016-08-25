//
//  IGCExtensionTests.swift
//  Iguazu
//
//  Created by Engin Kurutepe on 17/06/2016.
//  Copyright © 2016 Fifteen Jugglers Software. All rights reserved.
//

import XCTest
@testable import Iguazu

class IGCExtensionTests: XCTestCase {

    let iLine = "I023638FXA3941ENL"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleILine() {
        guard let extensions = IGCExtension.parseExtensions(line: iLine) else { XCTFail("could not parse \(iLine)"); return }

        XCTAssertEqual(extensions.count, 2)

        let firstExtension = extensions[0]

        XCTAssertEqual(firstExtension.startIndex, 36)
        XCTAssertEqual(firstExtension.endIndex, 38)
        XCTAssertEqual(firstExtension.type, IGCExtension.ExtensionType.fixAccuracy)

        let secondExtension = extensions[1]

        XCTAssertEqual(secondExtension.startIndex, 39)
        XCTAssertEqual(secondExtension.endIndex, 41)
        XCTAssertEqual(secondExtension.type, IGCExtension.ExtensionType.engineNoiseLevel)
    }
}
