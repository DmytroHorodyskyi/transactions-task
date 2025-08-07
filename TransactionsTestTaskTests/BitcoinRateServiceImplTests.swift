//
//  BitcoinRateServiceImplTests.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 07.08.2025.
//

import XCTest
import Combine
@testable import TransactionsTestTask

final class BitcoinRateServiceImplTests: XCTestCase {
    
    // MARK: MockNetworkSession
    final class MockNetworkSession: NetworkSessionProtocol {
        var data: Data?
        var error: Error?
        
        func dataTask(
            with url: URL,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
        ) -> NetworkSessionDataTaskProtocol {
            return MockURLSessionDataTask {
                completionHandler(self.data, nil, self.error)
            }
        }
    }
    
    // MARK: MockURLSessionDataTask
    final class MockURLSessionDataTask: NetworkSessionDataTaskProtocol {
        private let closure: () -> Void
        init(closure: @escaping () -> Void) {
            self.closure = closure
        }
        func resume() {
            closure()
        }
    }
    
    // MARK: MockUserDefaultsService
    final class MockUserDefaultsService: UserDefaultsService {
        
        private var storage: [String: Any] = [:]
        
        func set(
            _ value: Any,
            forKey key: UserDefaultsKeys
        ) {
            storage[key.rawValue] = value
        }
        
        func get<T>(forKey key: UserDefaultsKeys) -> T? {
            return storage[key.rawValue] as? T
        }
    }
    
    // MARK: MockAnalyticsService
    final class MockAnalyticsService: AnalyticsService {
        
        func trackEvent(name: String, parameters: [String : String]) {
            print("\(name), \(parameters)")
        }
    }
    
    // MARK: Properties
    var mockAnalytics: MockAnalyticsService!
    var mockUserDefaults: MockUserDefaultsService!
    var mockNetworkSession: MockNetworkSession!
    var sut: BitcoinRateServiceImpl! // System Under Test
    
    // MARK: Setup / Teardown
    override func setUp() {
        super.setUp()
        
        mockAnalytics = MockAnalyticsService()
        mockUserDefaults = MockUserDefaultsService()
        mockNetworkSession = MockNetworkSession()
        
        sut = BitcoinRateServiceImpl(
            analyticsService: mockAnalytics,
            userDefaultsService: mockUserDefaults,
            networkSession: mockNetworkSession
        )
    }
    
    override func tearDown() {
        sut = nil
        mockAnalytics = nil
        mockUserDefaults = nil
        mockNetworkSession = nil
        
        super.tearDown()
    }
}

// MARK: - Tests
extension BitcoinRateServiceImplTests {
    
    func testFetchRatePublishesCorrectValue() {
        // Prepare mock response
        let jsonString = """
        {
            "Data": {
                "BTC-USD": {
                    "PRICE": 9999.99
                }
            }
        }
        """
        mockNetworkSession.data = jsonString.data(using: .utf8)
        mockNetworkSession.error = nil
        
        let expectation = XCTestExpectation(description: "Rate published")
        
        var receivedRate: Double?
        let cancellable = sut.ratePublisher.sink { rate in
            receivedRate = rate
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(receivedRate, 9999.99)
        cancellable.cancel()
    }
}
