//
//  URLSession+NetworkSessionProtocol.swift
//  TransactionsTestTask
//
//  Created by Dmytro Horodyskyi on 07.08.2025.
//

import Foundation

protocol NetworkSessionProtocol {
    func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> NetworkSessionDataTaskProtocol
}

extension URLSession: NetworkSessionProtocol {
    func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> NetworkSessionDataTaskProtocol {
        let task: URLSessionDataTask = self.dataTask(
            with: url,
            completionHandler: completionHandler
        )
        return task as NetworkSessionDataTaskProtocol
    }
}
