//
//  MainPresenter.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 27.04.2025.
//

import Foundation

protocol MainViewInputProtocol: AnyObject {
    
    /// Обновить экран с загруженными новостями.
    /// - Parameter news: Массив новостей.
    func updateScreen(with news: [News])
    
    /// Не удалось обновить экран с новостями.
    /// - Parameter error: Ошибка получения новостей.
    func failure(error: Error)
    
    /// Показывает, что новость уже добавлена в избранное.
    func showAlreadyFavoriteMessage()
    
    func showError(_ error: NewsServiceError)
}

final class MainPresenter: MainViewOutputProtocol {
    
    // MARK: - Private properites
    
    weak private var view: MainViewInputProtocol?
    
    private var news: [News] = []
    private var isFirstAppear = true
    private(set) var favoriteArticles: [News] = []
    
    private let service: NewsServiceProtocol
    
    //MARK: - Methods
    
    func fetchNews() {
        self.service.fetchNews { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let articles):
                    self?.news = articles
                    self?.view?.updateScreen(with: self?.news ?? [])
                case .failure(let error):
                    self?.view?.showError(error)
                }
            }
        }
    }

    func saveToFavorites(article: News) {
        if CoreDataManager.shared.isFavorite(article: article) {
            DispatchQueue.main.async {
                self.view?.showAlreadyFavoriteMessage()
            }
            return
        }
        CoreDataManager.shared.saveArticle(article: article)
        NotificationCenter.default.post(name: .didAddFavorite,
                                        object: nil)
    }

    // MARK: - Init
    
    init(view: MainViewInputProtocol, service: NewsServiceProtocol) {
        self.view = view
        self.service = service
    }
    
    //MARK: - MainViewOutputProtocol
    
    func viewDidLoad() {
        self.fetchNews()
        self.view?.updateScreen(with: self.news)
        NetworkMonitor.shared.didBecomeReachable = { [weak self] in
            self?.fetchNews()
        }
    }
    
    func viewDidAppear() {
        if !self.isFirstAppear {
            self.view?.updateScreen(with: self.news)
        }
        self.isFirstAppear = false
    }
    
    func isArticleFavorite(_ article: News) -> Bool {
        favoriteArticles.contains(where: { $0.url == article.url })
    }
}
