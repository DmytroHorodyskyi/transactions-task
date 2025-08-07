//
//  BitcoinRateService.swift
//  TransactionsTestTask
//
//

import Foundation
import Combine

protocol BitcoinRateService: AnyObject {
    
    var ratePublisher: PassthroughSubject<Double, Never> { get }
}

final class BitcoinRateServiceImpl: BitcoinRateService {
    
    // MARK: Properties
    private let analyticsService: AnalyticsService
    private let userDefaultsService: UserDefaultsService
    private let networkSession: NetworkSessionProtocol
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    let ratePublisher = PassthroughSubject<Double, Never>()
    
    init(
        analyticsService: AnalyticsService,
        userDefaultsService: UserDefaultsService,
        networkSession: NetworkSessionProtocol = URLSession.shared
    ) {
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        self.networkSession = networkSession
        startRateUpdates()
    }
}

// MARK: - Private methods
extension BitcoinRateServiceImpl {
    
    func startRateUpdates() {
        if let rate: Double = userDefaultsService.get(forKey: .bitcoinRate) {
            ratePublisher.send(rate)
        }
        fetchRate()
        scheduleFetch(interval: 120)
    }

     func scheduleFetch(interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: interval,
            target: self,
            selector: #selector(fetchRate),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func fetchRate() {
        guard let url = URL(string: "https://data-api.coindesk.com/spot/v1/latest/tick?market=coinbase&instruments=BTC-USD")
        else { return }

        networkSession.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self,
                  let data = data,
                  error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataDict = json["Data"] as? [String: Any],
                  let btcUsd = dataDict["BTC-USD"] as? [String: Any],
                  let rate = btcUsd["PRICE"] as? Double
            else { return }

            self.userDefaultsService.set(rate, forKey: .bitcoinRate)

            DispatchQueue.main.async {
                self.ratePublisher.send(rate)
                self.analyticsService.trackEvent(
                    name: "bitcoin_rate_update",
                    parameters: ["rate": String(format: "%.2f", rate)]
                )
            }
        }.resume()
    }
}
