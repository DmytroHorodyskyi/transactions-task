//
//  MainViewController.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine

final class MainViewController: UIViewController {
    
    // MARK: Properties
    private let contentView = MainContentView()
    
    private let servicesAssembler: ServicesAssembler
    private let bitcoinRateService: BitcoinRateService
    private let userDefaultsService: UserDefaultsService
    private let storageService: StorageService

    private var cancellables = Set<AnyCancellable>()
    
    private var bitcoinRate: Double = 0 {
        didSet {
            contentView.updateRateLabel(to: bitcoinRate)
        }
    }
    
    private var balance: Double = 0 {
        didSet {
            contentView.updateBalanceLabel(to: balance)
        }
    }
    
    private var allTransactions: [Transaction] = []
    private var groupedTransactions: [(date: Date, transactions: [Transaction])] = []
    
    private var currentPage = 0
    private let pageSize = 20
    private var isLoading = false
    private var allLoaded = false

    // MARK: LifeCycle
    init(servicesAssembler: ServicesAssembler) {
        self.servicesAssembler = servicesAssembler
        self.bitcoinRateService = servicesAssembler.bitcoinRateService
        self.userDefaultsService = servicesAssembler.userDefaultsService
        self.storageService = servicesAssembler.storageService
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
        
        contentView.transactionTableView.dataSource = self
        contentView.transactionTableView.delegate = self
        contentView.transactionTableView.register(
            TransactionTableViewCell.self,
            forCellReuseIdentifier: "TransactionTableViewCell"
        )
        
        setupBitcoinRateLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetAndLoad()
    }
}

// MARK: - Private methods
private extension MainViewController {
    
    func setupBitcoinRateLabel() {
        bitcoinRateService
            .ratePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newRate in
                self?.bitcoinRate = newRate
            }
            .store(in: &cancellables)
    }
    
    func resetAndLoad() {
        currentPage = 0
        allTransactions = []
        groupedTransactions = []
        allLoaded = false
        loadNextPage()
        balance = userDefaultsService.get(forKey: .balance) ?? 0
    }
    
    func loadNextPage() {
        guard !isLoading,
              !allLoaded
        else { return }
        isLoading = true

        let offset = currentPage * pageSize
        let newItems = storageService.fetchTransactions(
            offset: offset,
            limit: pageSize
        )
        if newItems.isEmpty {
            allLoaded = true
            isLoading = false
            return
        }
        allTransactions += newItems
        groupedTransactions = Dictionary(grouping: allTransactions) {
            $0.date?.startOfDay ?? Date.distantPast
        }
        .sorted { $0.key > $1.key }
        .map { (date: $0.key, transactions: $0.value) }
        currentPage += 1
        isLoading = false
        contentView.transactionTableView.reloadData()
    }
}

// MARK: - MainContentViewDelegate
extension MainViewController: MainContentViewDelegate {
    
    func presentAlertController(_ controller: UIAlertController) {
        present(
            controller,
            animated: true
        )
    }
    
    func didEnterReplenishmentAmount(_ amount: String) {
        guard let value = amount.normalizedDouble
        else { return }
        balance += value
        userDefaultsService.set(
            balance,
            forKey: .balance
        )
        storageService.createTransaction(
            date: Date(),
            amount: value,
            type: .replenishment
        )
        resetAndLoad()
    }
    
    func navigateToAddTransaction() {
        navigationController?.pushViewController(
            AddTransactionViewCotroller(servicesAssembler: servicesAssembler),
            animated: true
        )
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        groupedTransactions.count
    }

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        groupedTransactions[section].transactions.count
    }

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        let date = groupedTransactions[section].date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "TransactionTableViewCell",
            for: indexPath
        ) as? TransactionTableViewCell else {
            return UITableViewCell()
        }
        
        let transaction = groupedTransactions[indexPath.section].transactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if position > (contentHeight - frameHeight - 100) {
            loadNextPage()
        }
    }
}
