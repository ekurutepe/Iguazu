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
}
