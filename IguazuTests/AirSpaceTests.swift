import XCTest
@testable import Iguazu

class AirSpaceTests : XCTestCase {

    var url: URL!
    override func setUp() {
        super.setUp()
        do {
            url = Bundle(for: AirSpaceTests.self).url(forResource: "DAeC_Germany_Week22_2016", withExtension: "txt")
        }
        catch {
            XCTFail("\(dump(error))")
        }
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
        XCTAssertEqual(geoJson, "{\"type\":\"Feature\",\"properties\":{\"ceiling\":3048,\"name\":\"Alb-Nord_1 134.500\\/128.950\",\"type\":\"W\",\"floor\":1371},\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[9.1911111111111108,48.49111111111111],[9.1911111111111108,48.49111111111111],[9.1538888888888899,48.448888888888888],[9.6255555555555556,48.5625],[9.7336111111111094,48.609722222222224],[9.7349230892731793,48.609520950496226],[9.741929358825363,48.633060982012317],[9.746520437934155,48.656859742857833],[9.7486720047168376,48.680808933269006],[9.7472222222222218,48.680833333333332],[9.6236111111111118,48.648333333333333],[9.4222222222222225,48.574722222222228],[9.3727777777777774,48.565555555555555],[9.1911111111111108,48.49111111111111]]]}}")
        
    }
}
