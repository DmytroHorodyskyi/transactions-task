//
//  TransactionType.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 07.08.2025.
//

enum TransactionType: RawRepresentable {
    
    case replenishment
    case withdrawal(WithdrawalCategory)
    
    // MARK: Properties
    var rawValue: String {
        switch self {
        case .replenishment:
            return "replenishmant"
        case .withdrawal(let category):
            return "withdrawal:\(category.rawValue)"
        }
    }

    // MARK: Initialization
    init?(rawValue: String) {
        if rawValue == "replenishmant" {
            self = .replenishment
        } else if rawValue.hasPrefix("withdrawal:"),
                  let categoryString = rawValue.split(separator: ":").last,
                  let category = WithdrawalCategory(rawValue: String(categoryString)) {
            self = .withdrawal(category)
        } else {
            return nil
        }
    }
}

// MARK: - Equatable
extension TransactionType: Equatable {
    static func ==(lhs: TransactionType, rhs: TransactionType) -> Bool {
        switch (lhs, rhs) {
        case (.replenishment, .replenishment):
            return true
        case let (.withdrawal(cat1), .withdrawal(cat2)):
            return cat1 == cat2
        default:
            return false
        }
    }
}
