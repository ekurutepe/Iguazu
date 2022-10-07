import XCTest
@testable import Iguazu

class AirSpaceTests : XCTestCase {

    var url: URL!
    override func setUp() {
        super.setUp()
        url = Bundle(for: AirSpaceTests.self).url(forResource: "DAeC_Germany_Week22_2016", withExtension: "txt")
    }

    func testFileParsing() {
        let airSpaces = OpenAirParser().airSpaces(withContentsOf: url)
        XCTAssertNotNil(airSpaces)
        XCTAssertTrue(airSpaces!.count > 0)
    }
    
    func testGeoJsonEncoding() {
        let airSpaces = OpenAirParser().airSpaces(withContentsOf: url)
        XCTAssertNotNil(airSpaces)
        let asp = airSpaces!.sorted { $0.name < $1.name }.first!
        let geoJson = asp.geoJsonString!
        XCTAssert(geoJson.hasPrefix("{\"type\":\"Feature\",\"properties\":{\"ceiling\":3048,\"name\":\"Alb-Nord_1 134.500\\/128.950\",\"type\":\"W\",\"floor\":1371},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[["))
        
    }
}
