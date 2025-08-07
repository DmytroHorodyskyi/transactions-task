//
//  TransactionTableViewCell.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 07.08.2025.
//

import UIKit

final class TransactionTableViewCell: UITableViewCell {

    // MARK: Properties
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.addArrangedSubview(timeLabel)
        stack.addArrangedSubview(amountStack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 18,
            weight: .regular
        )
        return label
    }()
    
    private lazy var amountStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .trailing
        stack.addArrangedSubview(amountLabel)
        stack.addArrangedSubview(categoryLabel)
        return stack
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 20,
            weight: .heavy
        )
        return label
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 18,
            weight: .thin
        )
        return label
    }()
    
    // MARK: LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Private methods
private extension TransactionTableViewCell {
    
    func setupUI() {
        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate(
            [
                mainStack.topAnchor.constraint(
                    equalTo: contentView.topAnchor,
                    constant: 8
                ),
                mainStack.bottomAnchor.constraint(
                    equalTo: contentView.bottomAnchor,
                    constant: -8
                ),
                mainStack.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: 16
                ),
                mainStack.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor,
                    constant: -16
                )
            ]
        )
    }
}

// MARK: - Public methods
extension TransactionTableViewCell {
    
    func configure(with transaction: Transaction) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        if let date = transaction.date {
            timeLabel.text = formatter.string(from: date)
        }

        guard let type = transaction.type else {
            amountLabel.text = "\(transaction.amount) ₿"
            categoryLabel.text = ""
            return
        }

        switch type {
        case .replenishment:
            amountLabel.text = "+\(transaction.amount) ₿"
            
        case .withdrawal(let category):
            amountLabel.text = "-\(transaction.amount) ₿"
            categoryLabel.text = category.rawValue.capitalized
        }
    }
}
