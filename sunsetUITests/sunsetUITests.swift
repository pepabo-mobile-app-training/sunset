//
//  sunsetUITests.swift
//  sunsetUITests
//
//  Created by usr0600429 on 2016/09/08.
//  Copyright © 2016年 GMO Pepabo. All rights reserved.
//

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

    // 年の切り替わりによる月の変更 (12から1月、またその逆の対策)
    func calcDate(year: Int, month: String, check: String) -> String {
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
    
    func testMoveMonthButton() {
        let app = XCUIApplication()
        
        let agoButton = app.buttons["←"]
        let laterButton = app.buttons["→"]
        let dateLabel = app.staticTexts["dateLabel"]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        let date = Date()
        let this_year = Int(formatter.string(from: date).components(separatedBy: " ")[1])!
        let this_month = formatter.string(from: date).components(separatedBy: " ")[0]
        var expectedLabel = ""
        
        XCTAssertEqual(this_month + " " + String(this_year), dateLabel.label)
        
        // 1ヶ月戻る
        agoButton.tap()
        
        expectedLabel = calcDate(year: this_year, month: this_month, check: "-")
        XCTAssertEqual(expectedLabel, dateLabel.label)
        
        // スタート時に戻る
        laterButton.tap()
        
        // 1ヶ月進む
        laterButton.tap()
        
        expectedLabel = calcDate(year: this_year, month: this_month, check: "+")
        XCTAssertEqual(expectedLabel, dateLabel.label)
        
    }
    
    func testShowPosts() {
        let app = XCUIApplication()
        let agoButton = app.buttons["←"]
        let laterButton = app.buttons["→"]
        
        agoButton.tap()
        XCTAssertTrue(app.tables.staticTexts["Apple"].exists)
        XCTAssertFalse(app.tables.staticTexts["Test Post"].exists)
        laterButton.tap()
        XCTAssertTrue(app.tables.staticTexts["Test Post"].exists)
        XCTAssertFalse(app.tables.staticTexts["Apple"].exists)
    }

}