//
//  Dare+startOfDay.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 07.08.2025.
//

import Foundation

extension Date {
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
