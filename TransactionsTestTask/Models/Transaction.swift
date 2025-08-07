//
//  Transaction.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 07.08.2025.
//

import Foundation
import CoreData

final class Transaction: NSManagedObject {
    
    // MARK: Properties
    var type: TransactionType? {
        get {
            guard let raw = typeRaw else { return nil }
            return TransactionType(rawValue: raw)
        }
        set {
            typeRaw = newValue?.rawValue
        }
    }
    
    // MARK: Initialization
    convenience init(
        context: NSManagedObjectContext,
        date: Date,
        amount: Double,
        type: String
    ) {
        self.init(context: context)
        self.date = date
        self.amount = amount
        self.typeRaw = type
    }
}
