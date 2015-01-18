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
        // noop
    }
    
    override func tearDown() {
        // noop
        super.tearDown()
    }

    func testCurrencyRatesFetcher_fetch() {
        let expectation = expectationWithDescription("SalaryZenKit.fetcher.fetch")
        SalaryZenKit.fetcher.fetch {
            (rates) in

            XCTAssertNotNil(rates.getCurrentCbrUsdRate())

            let (alfaSell, alfaBuy) = rates.getCurrentAlfaUsdRates()
            XCTAssertNotNil(alfaSell)
            XCTAssertNotNil(alfaBuy)

            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }
}

