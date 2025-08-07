//
//  StorageService.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 07.08.2025.
//

import CoreData
import UIKit

protocol StorageService {
    
    func createTransaction(
        date: Date,
        amount: Double,
        type: TransactionType
    )
    func fetchTransactions(
        offset: Int,
        limit: Int
    ) -> [Transaction]
}

final class StorageServiceImpl: StorageService {

    private let analyticsService: AnalyticsService
    private let context: NSManagedObjectContext

    init(analyticsService: AnalyticsService, context: NSManagedObjectContext? = nil) {
        self.analyticsService = analyticsService
        if let context = context {
            self.context = context
        } else {
            let container = NSPersistentContainer(name: "TransactionsTestTask")
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("❌ Core Data load error: \(error.localizedDescription)")
                }
            }
            self.context = container.viewContext
        }
    }
}

// MARK: - Private methods
private extension StorageServiceImpl {
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("❌ Failed to save context: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Public methods
extension StorageServiceImpl {
    
    func createTransaction(
        date: Date,
        amount: Double,
        type: TransactionType
    ) {
        let transaction = Transaction(context: context)
        transaction.date = date
        transaction.amount = amount
        transaction.type = type
        saveContext()
        analyticsService.trackEvent(
            name: "transaction_created",
            parameters: [
                "date": date.description,
                "amount": amount.description,
                "category": type.rawValue
            ])
    }

    func fetchTransactions(
        offset: Int,
        limit: Int
    ) -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(
            key: "date",
            ascending: false
        )]
        request.fetchOffset = offset
        request.fetchLimit = limit
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Failed to fetch transactions: \(error.localizedDescription)")
            return []
        }
    }
}
