import XCTest

class sunsetUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launchArguments = [ "STUB_HTTP_ENDPOINTS" ]
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func changeDate(date: String, check: String) -> String {
        let month: String = date.components(separatedBy: " ")[0]
        let year = Int(date.components(separatedBy: " ")[1])!
        
        var calendarShortened = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        
        if check == "+" {
            if month == "Dec" {
                return "Jan " + String(year + 1)
            }
            else {
                return calendarShortened[calendarShortened.index(of: month)! + 1] + " " + String(year)
            }
        }

        else {
            if month == "Jan" {
                return "Dec " + String(year - 1)
            }
            else {
                return calendarShortened[calendarShortened.index(of: month)! - 1] + " " + String(year)
            }
        }

    }
    
    func testSwipeCalendar() {
        let app = XCUIApplication()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let now: String = formatter.string(from: Date())
        let nowDateLabel = app.staticTexts[now]
        XCTAssertTrue(nowDateLabel.exists)
        app.collectionViews.element.swipeRight()
        let prevDateLabel = changeDate(date: now, check: "-")
        XCTAssertTrue(app.staticTexts[prevDateLabel].exists)
    }
    
    func testShowPosts() {
        // STUBで定義された内容を元にテスト
        
        let app = XCUIApplication()
        
        app.collectionViews.element.swipeRight()
        XCTAssertTrue(app.tables.staticTexts["Apple"].exists)
        XCTAssertFalse(app.tables.staticTexts["Test Post"].exists)
        app.collectionViews.element.swipeLeft()
        XCTAssertTrue(app.tables.staticTexts["Test Post"].exists)
        XCTAssertFalse(app.tables.staticTexts["Apple"].exists)
    }
}
