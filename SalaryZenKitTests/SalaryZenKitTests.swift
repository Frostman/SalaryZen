//
//  SalaryZenKitTests.swift
//  SalaryZenKitTests
//
//  Created by Sergey Lukjanov on 11/01/15.
//  Copyright (c) 2015 Sergey Lukjanov. All rights reserved.
//

import UIKit
import XCTest

import SalaryZenKit

class SalaryZenKitTests: XCTestCase {
    
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
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSalaryZenAggregatorDataFetcher_updateRates() {
        let expectation = expectationWithDescription("SalaryZenAggregatorDataFetcher_updateRates")
        var callCounter = 0
        let handler: (info: CurrencyExchangeInfo) -> Void = {
            (info: CurrencyExchangeInfo) in
            callCounter++
            return
        }
        
        let infos = [CurrencyExchangeInfo(currency: Currency.USD, updateHandler: handler),
            CurrencyExchangeInfo(currency: Currency.EUR, updateHandler: handler)]
        
        currencyDataFetcher.updateRates(currencyExchangeInfos: infos) {
            (error) in
            XCTAssertFalse(error, "There should be no error fetching data.json")
            XCTAssertEqual(callCounter, 6, "CurrencyExchangeInfo objects should be updated 6 times")
            
            for info in infos {
                XCTAssertNotNil(info.nonCashBuyRate)
                XCTAssertNotNil(info.nonCashSellRate)
                XCTAssertNotNil(info.cbRate)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }
}

