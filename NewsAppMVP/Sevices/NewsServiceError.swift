//
//  NewsServiceError.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 01.07.2025.
//

import Foundation

enum NewsServiceError: Error {
    case invalidURL
    case requestFailed(Error)
    case noData
    case decodingFailed
}

