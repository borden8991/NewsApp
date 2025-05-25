//
//  NewsTableViewCell.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 27.04.2025.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    //MARK: - Constants
    
    static let identifier = "NewsTableViewCell"
    
    //MARK: - Private Properties
    
    private let newsImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let sourceLabel = UILabel()
    private let dateLabel = UILabel()
    
    //MARK: - Properties
    
    var favoriteButtonAction: (() -> Void)?
    let favoriteIcon: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "star"),
                        for: .normal)
        button.tintColor = .systemYellow
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
        setupUI()
        favoriteIcon.addTarget(self,
                               action: #selector(favoriteButtonTapped),
                               for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func favoriteButtonTapped() {
        favoriteButtonAction?()
    }
    
    private func setupUI() {
        newsImageView.contentMode = .scaleAspectFill
        newsImageView.clipsToBounds = true
        newsImageView.layer.cornerRadius = 8
        newsImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = .darkGray
        sourceLabel.font = UIFont.systemFont(ofSize: 12)
        sourceLabel.textColor = .gray
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .lightGray
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel,
                                                       descriptionLabel,
                                                       sourceLabel,
                                                       dateLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let mainStack = UIStackView(arrangedSubviews: [newsImageView,
                                                       textStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 10
        mainStack.alignment = .top
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            newsImageView.widthAnchor.constraint(equalToConstant: 100),
            newsImageView.heightAnchor.constraint(equalToConstant: 100),
            
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                               constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: -10),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                              constant: -10)
        ])
        
        contentView.addSubview(favoriteIcon)
        
        NSLayoutConstraint.activate([
            favoriteIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteIcon.centerYAnchor.constraint(equalTo: sourceLabel.centerYAnchor),
            favoriteIcon.widthAnchor.constraint(equalToConstant: 20),
            favoriteIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(with news: News) {
        titleLabel.text = news.title
        descriptionLabel.text = "Description: \(news.description ?? "-")"
        sourceLabel.text = "Source: \(news.source.name)"
        dateLabel.text = "Date: \(formatDate(news.publishedAt))"
        
        if let imageUrlString = news.urlToImage, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl)
        } else {
            newsImageView.image = UIImage(named: "placeholder")
        }
    }
    
    func configure(with favoriteArticle: FavoriteArticle) {
        titleLabel.text = favoriteArticle.title
        descriptionLabel.text = "Description: \(favoriteArticle.desc ?? "-")"
        sourceLabel.text = "Source \(favoriteArticle.source ?? "")"
        dateLabel.text = "Date: \(formatDate(favoriteArticle.publishedAt ?? ""))"
        
        if let imageUrlString = favoriteArticle.urlToImage, let imageUrl = URL(string: imageUrlString) {
            loadImage(from: imageUrl)
        } else {
            newsImageView.image = UIImage(named: "placeholder")
        }
    }
    
    func updateFavoriteState(isFavorite: Bool) {
        favoriteIcon.tintColor = isFavorite ? .systemYellow : .lightGray
    }
    
    private func loadImage(from url: URL) {
        newsImageView.image = UIImage(named: "placeholder")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self, let data, error == nil else { return }
            DispatchQueue.main.async {
                self.newsImageView.image = UIImage(data: data)
            }
        }.resume()
    }
    
    private func formatDate(_ isoDate: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: isoDate) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return isoDate
    }
}
