//
//  MainViewOutput.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 27.04.2025.
//

import Foundation

protocol MainViewOutputProtocol {
    
    /// Вьюха была загружена
    func viewDidLoad()
    
    /// Вьюха появилась
    func viewDidAppear()
    
    func fetchNews()

    func saveToFavorites(article: News)
    
    func isArticleFavorite(_ article: News) -> Bool
}
