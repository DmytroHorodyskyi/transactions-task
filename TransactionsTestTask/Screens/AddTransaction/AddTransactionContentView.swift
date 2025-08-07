//
//  AddTransactionContentView.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 06.08.2025.
//

import UIKit

protocol AddTransactionContentViewDelegate: UIViewController {
    func addTransaction(
        amount: Double,
        type: TransactionType
    )
}

final class AddTransactionContentView: UIView {
    
    // MARK: Properties
    weak var delegate: AddTransactionContentViewDelegate?
    
    private var stackBottomConstraint: NSLayoutConstraint?
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 25
        stack.addArrangedSubview(amountTextField)
        stack.addArrangedSubview(categorySegmentedControl)
        stack.addArrangedSubview(UIView())
        stack.addArrangedSubview(addButton)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "1"
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        let leftPaddingView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 12,
            height: 0
        ))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        let rightPaddingView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 12,
            height: 0
        ))
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
        textField.keyboardType = .decimalPad
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return textField
    }()
    
    private lazy var categorySegmentedControl: UISegmentedControl = {
        let segmentedItems = WithdrawalCategory.allCases.map { $0.rawValue.capitalized }
        let segmentedControl = UISegmentedControl(items: segmentedItems)
        let font = UIFont.systemFont(ofSize: 12)
        segmentedControl.setTitleTextAttributes(
            [NSAttributedString.Key.font: font],
            for: .normal
        )
        return segmentedControl
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle(
            "Add",
            for: .normal
        )
        button.setTitleColor(
            .black,
            for: .normal
        )
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(
            self,
            action: #selector(didTapAddButton),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupKeyboardInteraction()
        backgroundColor = .white
        addSubview(mainStack)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Private methods
private extension AddTransactionContentView {
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        else { return }

        let keyboardHeight = keyboardFrame.cgRectValue.height
        stackBottomConstraint?.constant = -keyboardHeight
        UIView.animate(withDuration: duration.doubleValue) {
            self.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        else { return }

        stackBottomConstraint?.constant = -16
        UIView.animate(withDuration: duration.doubleValue) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func dismissKeyboard() {
        endEditing(true)
    }
    
    @objc func didTapAddButton() {
        guard let amount = amountTextField.text?.normalizedDouble,
              categorySegmentedControl.selectedSegmentIndex >= 0
        else { return }
        delegate?.addTransaction(
            amount: amount,
            type: .withdrawal(WithdrawalCategory.allCases[categorySegmentedControl.selectedSegmentIndex])
        )
    }
    
    func setupKeyboardInteraction() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        addGestureRecognizer(tapGesture)
    }
    
    func setupConstraints() {
        stackBottomConstraint = mainStack.bottomAnchor.constraint(
            equalTo: safeAreaLayoutGuide.bottomAnchor,
            constant: -16
        )
        NSLayoutConstraint.activate(
            [
                mainStack.topAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.topAnchor,
                    constant: 16
                ),
                mainStack.leadingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.leadingAnchor,
                    constant: 16
                ),
                mainStack.trailingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.trailingAnchor,
                    constant: -16
                ),
                stackBottomConstraint ?? NSLayoutConstraint()
            ]
        )
    }
}
