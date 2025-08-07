//
//  AddTransactionViewCotroller.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 06.08.2025.
//

import UIKit

final class AddTransactionViewCotroller: UIViewController {
    
    // MARK: Properties
    private let contentView = AddTransactionContentView()
    
    private let storageService: StorageService
    private let userDefaultsService: UserDefaultsService
    
    // MARK: LifeCycle
    init(servicesAssembler: ServicesAssembler) {
        self.storageService = servicesAssembler.storageService
        self.userDefaultsService = servicesAssembler.userDefaultsService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.delegate = self
        contentView.frame = view.bounds
        view.addSubview(contentView)
    }
}

// MARK: - AddTransactionContentViewDelegate
extension AddTransactionViewCotroller: AddTransactionContentViewDelegate {
    
    func addTransaction(
        amount: Double,
        type: TransactionType
    ) {
        storageService.createTransaction(
            date: Date(),
            amount: amount,
            type: type
        )
        let currentBalance = userDefaultsService.get(forKey: .balance) ?? 0.0
        let newBalance = currentBalance - amount
        userDefaultsService.set(
            newBalance,
            forKey: .balance
        )
        navigationController?.popViewController(animated: true)
    }
}
