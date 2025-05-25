//
//  NewsService.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 28.04.2025.
//

import Foundation

protocol NewsServiceProtocol {
    func fetchNews(completion: @escaping (Result<[News], Error>) -> Void)
}

class NewsService: NewsServiceProtocol {
    
    func fetchNews(completion: @escaping (Result<[News], Error>) -> Void) {
        let urlString = "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=4d00a491c6304c209858f2c60cf9dc08"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                completion(.failure(error))
            } else if let data {
                do {
                    let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
                    completion(.success(newsResponse.articles))
                } catch {
                    completion(.failure(error))
                } 
            }
        }.resume()
    }
}
