//
//  StorageServiceImplTests.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 07.08.2025.
//

import XCTest
import CoreData
@testable import TransactionsTestTask

final class StorageServiceImplTests: XCTestCase {
    
    // MARK: MockAnalyticsService
    final class MockAnalyticsService: AnalyticsService {
        
        var trackedEvents: [(name: String, parameters: [String: String])] = []
        func trackEvent(name: String, parameters: [String : String]) {
            trackedEvents.append((name, parameters))
        }
    }
    
    // MARK: Properties
    var storageService: StorageServiceImpl!
    var mockAnalytics: MockAnalyticsService!
    var persistentContainer: NSPersistentContainer!
    
    // MARK: Setup / Teardown
    override func setUp() {
        super.setUp()
        
        guard let modelURL = Bundle(for: StorageServiceImplTests.self).url(forResource: "TransactionsTestTask", withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load model")
        }
        
        persistentContainer = NSPersistentContainer(
            name: "TransactionsTestTask",
            managedObjectModel: managedObjectModel
        )
        
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        
        let expectation = self.expectation(description: "Load persistent stores")
        persistentContainer.loadPersistentStores { (desc, error) in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        
        mockAnalytics = MockAnalyticsService()
        storageService = StorageServiceImpl(
            analyticsService: mockAnalytics,
            context: persistentContainer.viewContext
        )
    }
    
    override func tearDown() {
        storageService = nil
        mockAnalytics = nil
        persistentContainer = nil
        super.tearDown()
    }
}

// MARK: - Tests
extension StorageServiceImplTests {
    
    func testCreateTransaction_SavesTransactionAndTracksEvent() {
        let date = Date()
        let amount = 10.0
        let type: TransactionType = .replenishment
        
        storageService.createTransaction(date: date, amount: amount, type: type)
        
        let fetched = storageService.fetchTransactions(offset: 0, limit: 10)
        
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched[0].amount, amount)
        XCTAssertEqual(fetched[0].date!.timeIntervalSince1970, date.timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(fetched[0].type, type)
        
        XCTAssertEqual(mockAnalytics.trackedEvents.count, 1)
        let event = mockAnalytics.trackedEvents.first
        XCTAssertEqual(event?.name, "transaction_created")
        XCTAssertEqual(event?.parameters["amount"], "\(amount)")
        XCTAssertEqual(event?.parameters["category"], type.rawValue)
    }
    
    func testFetchTransactions_RespectOffsetAndLimit() {
        for i in 1...3 {
            storageService.createTransaction(
                date: Date().addingTimeInterval(TimeInterval(i)),
                amount: Double(i),
                type: .replenishment
            )
        }
        
        let fetched = storageService.fetchTransactions(offset: 0, limit: 2)
        XCTAssertEqual(fetched.count, 2)
        
        XCTAssertGreaterThan(fetched[0].date ?? Date.distantPast, fetched[1].date ?? Date.distantPast)
        
        let nextFetched = storageService.fetchTransactions(offset: 2, limit: 1)
        XCTAssertEqual(nextFetched.count, 1)
    }
}
