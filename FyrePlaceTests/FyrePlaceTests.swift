//
//  FyrePlaceTests.swift
//  FyrePlaceTests
//
//  Created by Steven Zhang on 2016-05-28.
//  Copyright © 2016 Steven Zhang. All rights reserved.
//

import XCTest
@testable import FyrePlace

class FyrePlaceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: FyrePlace Test
    
    /*func testFyreInitialization() {
        // Success Case
        let successTestCase = Fyre(name: "Test", photo: nil, option: "Option 1")
        XCTAssertNotNil(successTestCase)
        
        // Fail Cases
        let noNameCase = Fyre(name: "", photo: nil, option: "Option 1")
        XCTAssertNil(noNameCase, "Cannot initialize due to empty name string")
        
        let noOptionCase = Fyre(name: "Test 2", photo: nil, option: "")
        XCTAssertNil(noOptionCase, "Cannot initialize due to empty option string")
    }*/
    
}
