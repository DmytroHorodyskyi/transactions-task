//
//  UserDefaultsService.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 07.08.2025.
//

import Foundation

protocol UserDefaultsService {
    
    func set(
        _ value: Any,
        forKey key: UserDefaultsKeys
    )
    func get<T>(forKey key: UserDefaultsKeys) -> T?
}

final class UserDefaultsServiceImpl: UserDefaultsService {
    
    // MARK: Properties
    private var defaults: UserDefaults
    
    // MARK: Initialization
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
}

// MARK: - Public methods
extension UserDefaultsServiceImpl {
    func set(
        _ value: Any,
        forKey key: UserDefaultsKeys
    ) {
        defaults.set(
            value,
            forKey: key.rawValue
        )
    }

    func get<T>(forKey key: UserDefaultsKeys) -> T? {
        defaults.object(forKey: key.rawValue) as? T
    }
}
