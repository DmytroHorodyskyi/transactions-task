//
//  ServicesAssembler.swift
//  TransactionsTestTask
//
//

final class ServicesAssembler {
    
    // MARK: BitcoinRateService
    lazy var bitcoinRateService: BitcoinRateService = {
        BitcoinRateServiceImpl(
            analyticsService: analyticsService,
            userDefaultsService: userDefaultsService
        )
    }()

    // MARK: AnalyticsService
    lazy var analyticsService: AnalyticsService = {
        AnalyticsServiceImpl()
    }()

    // MARK: UserDefaultsService
    lazy var userDefaultsService: UserDefaultsService = {
        UserDefaultsServiceImpl()
    }()

    // MARK: StorageService
    lazy var storageService: StorageService = {
        StorageServiceImpl(analyticsService: analyticsService)
    }()
}
