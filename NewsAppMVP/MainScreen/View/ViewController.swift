//
//  ViewController.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 27.04.2025.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
    
    //MARK: - Properties
    
    var presenter: MainViewOutputProtocol?

    private var news: [News] = []
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let sortControl = UISegmentedControl(items: ["Sort by latest", "Sort by oldest"])
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredArticles: [News] = []
    private var isSearching: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        
        self.presenter?.fetchNews()
        self.presenter?.viewDidLoad()
        print("view did load")
        
        setupSortControl()
        setupTableView()
        setupSearchController()
        
        updateTabBarBadge()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("view did disappear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did appear")
        self.presenter?.viewDidAppear()
    }
    
    //MARK: - Private Methods
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: NewsTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self,
                                 action: #selector(refreshNews),
                                 for: .valueChanged)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: sortControl.bottomAnchor,
                                           constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func refreshNews() {
        presenter?.fetchNews()
    }
    
    private func setupSortControl() {
        view.addSubview(sortControl)
           sortControl.selectedSegmentIndex = 0
           sortControl.translatesAutoresizingMaskIntoConstraints = false
           
        NSLayoutConstraint.activate([
            sortControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sortControl.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                 constant: 16),
            sortControl.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -16)
        ])
        sortControl.addTarget(self,
                              action: #selector(sortChanged),
                              for: .valueChanged)
    }
    
    private func sortArticles() {
        switch sortControl.selectedSegmentIndex {
        case 0:
            news.sort { $0.publishedAt > $1.publishedAt }
        case 1:
            news.sort { $0.publishedAt < $1.publishedAt }
        default:
            break
        }

        if isSearching, let query = searchController.searchBar.text?.lowercased() {
            filteredArticles = news.filter {
                $0.title.lowercased().contains(query)
            }
        }
    }
    
    @objc private func sortChanged() {
        sortArticles()
        tableView.reloadData()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func showSavedAnimation() {
        let savedView = UIView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: 130,
                                             height: 130))
        savedView.center = view.center
        savedView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        savedView.layer.cornerRadius = 12
        
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 45,
                                 y: 35,
                                 width: 40,
                                 height: 40)
        savedView.addSubview(imageView)
        
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 90,
                                          width: 130,
                                          height: 30))
        label.text = "Добавлено!"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        savedView.addSubview(label)
        
        view.addSubview(savedView)
        
        UIView.animate(withDuration: 0.3, animations: {
            savedView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0.8, options: [], animations: {
                savedView.alpha = 0
            }) { _ in
                savedView.removeFromSuperview()
            }
        }
    }
    
    private func updateTabBarBadge() {
        let count = CoreDataManager.shared.fetchFavorites().count
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let tabBarController = (scene.windows.first { $0.isKeyWindow })?.rootViewController as? UITabBarController {
                
                let badgeValue = count > 0 ? "\(count)" : nil
                tabBarController.tabBar.items?[1].badgeValue = badgeValue
            }
        }
    }
}

//MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSearching ? filteredArticles.count : news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier, for: indexPath) as? NewsTableViewCell else {
            return UITableViewCell()
        }
        let article = isSearching ? filteredArticles[indexPath.row] : news[indexPath.row]
        let isFavorite = CoreDataManager.shared.isFavorite(article: article)
        cell.updateFavoriteState(isFavorite: isFavorite)
        cell.configure(with: article)

        cell.favoriteButtonAction = {
            let selectedArticle = self.isSearching ? self.filteredArticles[indexPath.row] : self.news[indexPath.row]
            
            if self.presenter?.isArticleFavorite(selectedArticle) != nil {
                self.presenter?.saveToFavorites(article: selectedArticle)
            }
            self.showSavedAnimation()
            tableView.reloadRows(at: [indexPath],
                                 with: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = isSearching ? filteredArticles[indexPath.row] : news[indexPath.row]
        guard let url = URL(string: article.url ?? " ") else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}

//MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let saveAction = UIContextualAction(style: .normal,
                                            title: "В избранное") { [weak self] _, _, completionHandler in
           guard let self else { return }
            let article = isSearching ? filteredArticles[indexPath.row] : news[indexPath.row]
            self.presenter?.saveToFavorites(article: article)
            self.showSavedAnimation()
            updateScreen(with: news)
            self.updateTabBarBadge()
            completionHandler(true)
        }
        saveAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [saveAction])
    }
}

//MARK: - UISearchResultsUpdating

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text?.lowercased(), !query.isEmpty else {
            filteredArticles = []
            tableView.reloadData()
            return
        }
        filteredArticles = news.filter { $0.title.lowercased().contains(query) }
        tableView.reloadData()
    }
}

//MARK: - MainViewInputProtocol

extension ViewController: MainViewInputProtocol {

    func updateScreen(with news: [News]) {
        self.news = news
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func failure(error: any Error) {
        print(error.localizedDescription)
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showAlreadyFavoriteMessage() {
        let alert = UIAlertController(title: "Внимание",
                                      message: "Эта новость уже добавлена в избранное.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default))
        present(alert, animated: true)

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

