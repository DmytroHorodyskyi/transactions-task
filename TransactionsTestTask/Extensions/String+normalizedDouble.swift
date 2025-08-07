//
//  String+normalizedDouble.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 07.08.2025.
//

extension String {
    
    var normalizedDouble: Double? {
        Double(self.replacingOccurrences(of: ",", with: "."))
    }
}
