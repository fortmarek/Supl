//
//  SuplUITests.swift
//  SuplUITests
//
//  Created by Marek Fořt on 11.08.15.
//  Copyright © 2015 Marek Fořt. All rights reserved.
//

import XCTest

class SuplUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        
        
        XCUIApplication().launch()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        setupSnapshot(XCUIApplication())
        
        _ = self.expectation(
            for: NSPredicate(format: "self.count = 1"),
            evaluatedWith: XCUIApplication().tables,
            handler: nil)
        self.waitForExpectations(timeout: 5.0, handler: nil)
        
        snapshot("main")
        
        XCUIApplication().navigationBars["Supl"].buttons["Settings"].tap()
        
        snapshot("settings")
        
        _ = self.expectation(
            for: NSPredicate(format: "self.count = 1"),
            evaluatedWith: XCUIApplication().tables,
            handler: nil)
        self.waitForExpectations(timeout: 5.0, handler: nil)
        
        let cells = XCUIApplication().tables.cells
        XCTAssertEqual(cells.count, 6)
        
        cells.element(boundBy: 4).tap()
        
        XCUIApplication().buttons["DALŠÍ"].tap()
        XCUIApplication().buttons["DALŠÍ"].tap()
        XCUIApplication().buttons["DALŠÍ"].tap()
        
        snapshot("walkthrough_login")
        
    
    }
    
}
