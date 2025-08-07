//
//  UserDefaultsServiceImplTests.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 07.08.2025.
//

import XCTest
@testable import TransactionsTestTask

final class UserDefaultsServiceImplTests: XCTestCase {
    
    // MARK: Properties
    private var userDefaults: UserDefaults!
    private var service: UserDefaultsServiceImpl!
    
    // MARK: Setup / Teardown
    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: "UserDefaultsServiceTests")
        userDefaults.removePersistentDomain(forName: "UserDefaultsServiceTests")
        
        service = UserDefaultsServiceImpl(defaults: userDefaults)
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: "UserDefaultsServiceTests")
        userDefaults = nil
        service = nil
        super.tearDown()
    }
}

// MARK: - Tests
extension UserDefaultsServiceImplTests {
    
    func testSetAndGetDouble() {
        let key = UserDefaultsKeys.bitcoinRate
        let value: Double = 12345.67
        
        service.set(value, forKey: key)
        
        let retrieved: Double? = service.get(forKey: key)
        
        XCTAssertEqual(retrieved, value)
    }

    func testGetReturnsNilForMissingKey() {
        let retrieved: Int? = service.get(forKey: .bitcoinRate)
        XCTAssertNil(retrieved)
    }
}
