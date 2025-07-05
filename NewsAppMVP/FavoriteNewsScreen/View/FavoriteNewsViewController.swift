//
//  FavoriteNewsViewController.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 27.04.2025.
//

import UIKit
import SafariServices

class FavoriteNewsViewController: UIViewController {
    
    //MARK: - Properties
    
    private let tableView = UITableView()
    private var favoriteArticles: [FavoriteArticle] = []
    var presenter: FavoriteNewsViewOutputProtocol?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorite"
        setupTableView()
        fetchFavorites()
        setupNavigationButton()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(fetchFavorites),
                                               name: .didAddFavorite,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavorites()
        print("viewWillAppear")
    }
    
    //MARK: - Private Methods
    
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.register(NewsTableViewCell.self,
                           forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    private func updateBadge() {
        let count = favoriteArticles.count
        if count > 0 {
            tabBarItem.badgeValue = count > 99 ? "99+" : "\(count)"
        } else {
            tabBarItem.badgeValue = nil
        }
        animateTabBarItem()
    }
    
    private func animateTabBarItem() {
        guard let tabBarButton = tabBarController?.tabBar.subviews[1] else { return }

        UIView.animate(withDuration: 0.15,
                       animations: {
            tabBarButton.transform = CGAffineTransform(scaleX: 1.2,
                                                       y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) {
                tabBarButton.transform = CGAffineTransform.identity
            }
        })
    }
    
    @objc private func fetchFavorites() {
        favoriteArticles = CoreDataManager.shared.fetchFavorites()
        tableView.reloadData()
        updateBadge()
    }
    
    @objc private func clearFavorites() {
        CoreDataManager.shared.deleteAllFavorites()
        fetchFavorites()
    }
    
    private func setupNavigationButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(clearFavorites))
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate

extension FavoriteNewsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoriteArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: favoriteArticles[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = favoriteArticles[indexPath.row]
        if let urlString = article.url, let url = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self else { return }
            let article = self.favoriteArticles[indexPath.row]
            CoreDataManager.shared.deleteFavorite(article: article)
            self.favoriteArticles.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.updateBadge()
            NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
        
    }
}

extension FavoriteNewsViewController: FavoriteNewsViewInputProtocol { }

extension Notification.Name {
    static let didAddFavorite = Notification.Name("didAddFavorite")
}
