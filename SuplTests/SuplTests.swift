//
//  SuplTests.swift
//  SuplTests
//
//  Created by Marek Fořt on 22.02.16.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import XCTest
@testable import Supl

class SuplTests: XCTestCase {
    
    var vc: ViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewControllerWithIdentifier("suplVC") as? ViewController else {return}
        self.vc = viewController
        
        let _ = viewController.view
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
