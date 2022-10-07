import XCTest
@testable import Iguazu

class DateExtensionsTests : XCTestCase {

    let fixTime = "010135"
    let headerDate = "250809"
    func testHeaderDate() {
        let date = Date.parse(headerDateString: headerDate)
        XCTAssertEqual(date?.igcHeaderDate, headerDate)
    }
    
    func testFixTime() {
        let time = Date.parse(fixTimeString: fixTime, on: Date(timeIntervalSinceReferenceDate: 0))
        XCTAssertEqual(time?.igcFixTime, fixTime)
    }
    
}
