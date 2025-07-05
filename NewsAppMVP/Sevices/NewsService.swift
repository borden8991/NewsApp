//
//  NewsService.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 28.04.2025.
//

import Foundation

protocol NewsServiceProtocol {
    func fetchNews(completion: @escaping (Result<[News], NewsServiceError>) -> Void)
}

class NewsService: NewsServiceProtocol {
    
    func fetchNews(completion: @escaping (Result<[News], NewsServiceError>) -> Void) {
        guard let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=4d00a491c6304c209858f2c60cf9dc08") else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                completion(.failure(.requestFailed(error)))
                return
            }

            guard let data else {
                completion(.failure(.noData))
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(NewsResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(response.articles))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(.decodingFailed))
                    }
                }
            }
        }.resume()
    }
}
