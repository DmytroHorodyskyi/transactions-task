//
//  MainContentView.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 06.08.2025.
//

import UIKit

protocol MainContentViewDelegate: UIViewController {
    func presentAlertController(_ controller: UIAlertController)
    func didEnterReplenishmentAmount(_ amount: String)
    func navigateToAddTransaction()
}

final class MainContentView: UIView {
    
    // MARK: Properties
    weak var delegate: MainContentViewDelegate?
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 55
        stack.addArrangedSubview(bitcoinRateLabel)
        stack.addArrangedSubview(balanceStack)
        stack.addArrangedSubview(addTransactionButton)
        stack.addArrangedSubview(transactionTableView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var bitcoinRateLabel: UILabel = {
        let label = UILabel()
        label.text = "1 ₿ = 24.50 $"
        label.textAlignment = .right
        return label
    }()
    
    private lazy var balanceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 15
        stack.addArrangedSubview(balanceLabel)
        stack.addArrangedSubview(replenishButton)
        return stack
    }()
    
    private lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.text = "\(10) ₿"
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 50, weight: .heavy)
        return label
    }()
    
    private lazy var replenishButton: UIButton = {
        let button = UIButton()
        let titleImage = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        button.setImage(titleImage, for: .normal)
        button.tintColor = .black
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 8
        button.addTarget(
            self,
            action: #selector(replenishButtonTapped),
            for: .touchUpInside
        )
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    private lazy var addTransactionButton: UIButton = {
        let button = UIButton()
        button.setTitle(
            "Add transaction",
            for: .normal
        )
        button.setTitleColor(
            .black,
            for: .normal
        )
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.addTarget(
            self,
            action: #selector(addTransactionButtonTapped),
            for: .touchUpInside
        )
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return button
    }()
    
    let transactionTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 70
        return tableView
    }()
    
    // MARK: LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(mainStack)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Private methods
private extension MainContentView {
    
    func setupConstraints() {
        NSLayoutConstraint.activate(
            [
                mainStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                mainStack.leadingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.leadingAnchor,
                    constant: 16
                ),
                mainStack.trailingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.trailingAnchor,
                    constant: -16
                ),
                mainStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                
                bitcoinRateLabel.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
                bitcoinRateLabel.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
                
                addTransactionButton.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
                addTransactionButton.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
                
                transactionTableView.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
                transactionTableView.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
            ]
        )
    }
    
    @objc func replenishButtonTapped() {
        let alertController = UIAlertController(
            title: "Replenishment",
            message: "Enter the amount ₿ to replenish",
            preferredStyle: .alert
        )
        alertController.addTextField { (textField) in
            textField.placeholder = "10"
            textField.keyboardType = .decimalPad
        }
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        )
        let replenishAction = UIAlertAction(
            title: "Replenish",
            style: .default
        ) { [weak self] _ in
            let input = alertController.textFields?.first?.text ?? ""
            self?.delegate?.didEnterReplenishmentAmount(input)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(replenishAction)
        delegate?.presentAlertController(alertController)
    }
    
    @objc func addTransactionButtonTapped() {
        delegate?.navigateToAddTransaction()
    }
}

// MARK: - Public methods
extension MainContentView {
    
    func updateRateLabel(to newValue: Double) {
        bitcoinRateLabel.text = "1 ₿ = \(newValue) $"
    }
    
    func updateBalanceLabel(to newValue: Double) {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10

        if let formatted = formatter.string(from: NSNumber(value: newValue)) {
            balanceLabel.text = "\(formatted) ₿"
        } else {
            balanceLabel.text = "\(newValue) ₿"
        }
    }
}
