//
//  AnalyticsService.swift
//  TransactionsTestTask
//
//

import Foundation

protocol AnalyticsService: AnyObject {
    
    func trackEvent(
        name: String,
        parameters: [String: String]
    )
}

final class AnalyticsServiceImpl: AnalyticsService {
    
    // MARK: Properties
    private var events: [AnalyticsEvent] = []
}

//MARK: - Methods
extension AnalyticsServiceImpl {
    
    func trackEvent(
        name: String,
        parameters: [String: String]
    ) {
        let event = AnalyticsEvent(
            name: name,
            parameters: parameters,
            date: .now
        )
        events.append(event)
        print("Analytics event: \(event)")
    }
}
