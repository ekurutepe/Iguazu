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
    let crewHeaderString = "HFCM2CREW2:Bob Dylan"
    let gliderTypeString = "HFGTYGLIDERTYPE: Schleicher ASH-25"
    let gliderRegistrationString = "HFGIDGLIDERID: N116 EL"
    let tailfinNumberString = "HFCIDCOMPETITIONID: EH"
    let competitionClassString = "HFCCLCOMPETITIONCLASS:15m Motor Glider"
    
    var fullIGCString = ""
    
    var header: IGCHeader!
    
    override func setUp() {
        super.setUp()
        do {
            let path = Bundle(for: IGCHeaderTests.self).path(forResource: "lx7007", ofType: "igc")
            fullIGCString = try String(contentsOfFile: path!)
            header = IGCHeader(igcString: fullIGCString)
        }
        catch _ {
            XCTFail()
        }
    }

    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Test for public header API
    
    func testHeaderInit() {
        XCTAssertNotNil(header)
    }
    
    func testHeaderDate() {
        let d = header.flightDate
        print(d)
        XCTAssertEqual(d.timeIntervalSinceReferenceDate, 272851200.0)
    }
    
    func testHeaderPic() {
        XCTAssertEqual(header.pilotInCharge, "Ian Forster-Lewis")
    }
    
    func testHeaderCrew() {
        XCTAssertNil(header.crew)
    }
    
    func testHeaderGliderType() {
        XCTAssertEqual(header.gliderType, "LS_8-18")
    }
    
    func testHeaderGliderRegistration() {
        XCTAssertEqual(header.gliderRegistration, "G_CKPM")
    }

    func testOudieHeader() {
        let headerString: String
        do {
            let path = Bundle(for: IGCDataTests.self).path(forResource: "oudie", ofType: "igc")
            headerString = try String(contentsOfFile: path!)
        }
        catch _ {
            XCTFail()
            return
        }

        let header = IGCHeader(igcString: headerString)

        XCTAssertNotNil(header, "nil Oudie Header")
        XCTAssertEqual(header?.flightDate.description, "2020-03-12 00:00:00 +0000")
    }
    
    // MARK: - Tests for line parsing

    func testDateHeader() {
        guard let dateHeader = IGCHeaderField.parseHLine(hLine: dateHeaderString) else { XCTFail("expecting a date header but got nil"); return }
        switch dateHeader {
        case .date(let d):
            print("date \(d)")
            XCTAssertTrue(d.timeIntervalSinceReferenceDate == 272851200.0)
        default:
            XCTFail("expecting a date header but got something else")
        }

        return
    }

    func testAccuracyHeader() {
        guard let accuracyHeader = IGCHeaderField.parseHLine(hLine: accuracyHeaderString) else { XCTFail("expecting a accuracy header but got nil"); return }
        switch accuracyHeader {
        case .accuracy(let acc):
            print("accuracy \(acc)")
            XCTAssertEqual(acc, 100)
        default:
            XCTFail("expecting a accuracy header but got something else")
        }
        return
    }

    func testPilotHeader() {
        guard let pilotHeader = IGCHeaderField.parseHLine(hLine: pilotHeaderString) else { XCTFail("expecting a pilot header but got nil"); return }
        switch pilotHeader {
        case .pilotInCharge(let name):
            print("pilot name \(name)")
            XCTAssertEqual(name, "Ian Forster-Lewis")
        default:
            XCTFail("expecting a pilot header but got something else")
        }

        return
    }

    func testPilotLongHeader() {
        guard let pilotHeader = IGCHeaderField.parseHLine(hLine: pilotHeaderLongString) else { XCTFail("expecting a pilot header but got nil"); return }
        switch pilotHeader {
        case .pilotInCharge(let name):
            print("pilot name \(name)")
            XCTAssertEqual(name, "Ian Forster-Lewis")
        default:
            XCTFail("expecting a pilot header but got something else")
        }

        return
    }

    func testCrewHeader() {
        guard let header = IGCHeaderField.parseHLine(hLine: crewHeaderString) else { XCTFail("expecting a crew header but got nil"); return }
        switch header {
        case .crew(let name):
            print("pilot name \(name)")
            XCTAssertEqual(name, "Bob Dylan")
        default:
            XCTFail("expecting a crew header but got something else")
        }

        return
    }

    func testGliderTypeHeader() {
        guard let header = IGCHeaderField.parseHLine(hLine: gliderTypeString) else { XCTFail("expecting a glider header but got nil"); return }
        switch header {
        case .gliderType(let type):
            print("glider type \(type)")
            XCTAssertEqual(type, "Schleicher ASH-25")
        default:
            XCTFail("expecting a glider type header but got something else")
        }

        return
    }

    func testGliderRegistrationHeader() {
        guard let header = IGCHeaderField.parseHLine(hLine: gliderRegistrationString) else { XCTFail("expecting a reg header but got nil"); return }
        switch header {
        case .gliderRegistration(let registration):
            print("glider registration \(registration)")
            XCTAssertEqual(registration, "N116 EL")
        default:
            XCTFail("expecting a glider registration header but got something else")
        }

        return
    }

    func testCompetitionIDHeader() {
        guard let header = IGCHeaderField.parseHLine(hLine: tailfinNumberString) else { XCTFail("expecting a comp ID header but got nil"); return }
        switch header {
        case .competitionID(let tailfin):
            print("glider registration \(tailfin)")
            XCTAssertEqual(tailfin, "EH")
        default:
            XCTFail("expecting a competition ID header but got something else")
        }

        return
    }

    func testCompetitionClassHeader() {
        guard let header = IGCHeaderField.parseHLine(hLine: competitionClassString) else { XCTFail("expecting a class header but got nil"); return }
        switch header {
        case .competitionClass(let cClass):
            print("competition class \(cClass)")
            XCTAssertEqual(cClass, "15m Motor Glider")
        default:
            XCTFail("expecting a competition class header but got something else")
        }

        return
    }
}
