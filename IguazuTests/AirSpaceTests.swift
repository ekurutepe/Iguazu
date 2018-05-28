import XCTest
@testable import Iguazu

class AirSpaceTests : XCTestCase {

    var openAirString = ""
    
    override func setUp() {
        super.setUp()
        do {
            let url = Bundle(for: AirSpaceTests.self).url(forResource: "DAeC_Germany_Week22_2016", withExtension: "txt")
            openAirString = try String(contentsOf: url!, encoding: .ascii)
        }
        catch {
            XCTFail("\(dump(error))")
        }
    }

    func testFileParsing() {
        let airSpaces = AirSpace.airSpaces(from: self.openAirString)
        XCTAssertNotNil(airSpaces)
        XCTAssertTrue(airSpaces!.count > 0)
    }
    
    func testGeoJsonEncoding() {
        let airSpaces = AirSpace.airSpaces(from: self.openAirString)
        XCTAssertNotNil(airSpaces)
        let asp = airSpaces![0]
        let geoJson = asp.geoJsonString
        XCTAssertEqual(geoJson, "{\"type\":\"Feature\",\"properties\":{\"ceiling\":{\"type\":\"fl\",\"value\":65},\"name\":\"TMZ-EDLW 129.875\",\"type\":\"TMZ\",\"floor\":{\"type\":\"msl\",\"value\":4500,\"unit\":\"ft\"}},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[7.3055555555555554,51.516666666666666],[7.3055555555555554,51.516666666666666],[7.3433333333333328,51.423888888888889],[7.4625000000000004,51.31305555555555],[7.4519444444444449,51.408333333333331],[7.3741666666666665,51.493055555555557],[7.3055555555555554,51.516666666666666]]]}}")
        
    }
}
