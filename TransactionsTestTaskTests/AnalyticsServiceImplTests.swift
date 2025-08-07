//
//  AnalyticsServiceImplTests.swift
//  TransactionsTestTaskTests
//
//

import XCTest
@testable import TransactionsTestTask

final class AnalyticsServiceImplTests: XCTestCase {
    
    // MARK: Properties
    var analyticsService: AnalyticsServiceImpl!
    
    // MARK: Setup / Teardown
    override func setUp() {
        super.setUp()
        analyticsService = AnalyticsServiceImpl()
    }
    
    override func tearDown() {
        analyticsService = nil
        super.tearDown()
    }
}

// MARK: - Tests
extension AnalyticsServiceImplTests {
    
    func testTrackEvent_AppendsCorrectAnalyticsEvent() {
        let name = "Purchase"
        let parameters = ["item": "Bitcoin", "amount": "0.5"]
        
        analyticsService.trackEvent(
            name: name,
            parameters: parameters
        )
        
        let events = analyticsService.allEvents()
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.last?.name, name)
        XCTAssertEqual(events.last?.parameters, parameters)
        XCTAssertNotNil(events.last?.date)
    }
}
