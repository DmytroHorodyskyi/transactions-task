//
//  URLSessionDataTask+NetworkSessionDataTaskProtocol.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 07.08.2025.
//

import Foundation

protocol NetworkSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: NetworkSessionDataTaskProtocol {}
