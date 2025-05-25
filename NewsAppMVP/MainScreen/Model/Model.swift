//
//  Model.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 27.04.2025.
//

import Foundation

struct News: Decodable {
    let title: String
    let description: String?
    let source: Source
    let publishedAt: String
    let urlToImage: String?
    let url: String?
}

struct Source: Decodable {
    let name: String
}

struct NewsResponse: Decodable {
    let articles: [News]
}
