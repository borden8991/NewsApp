//
//  FavoriteNewsPresenter.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 27.04.2025.
//

import Foundation

protocol FavoriteNewsViewInputProtocol: AnyObject {
    
}

class FavoriteNewsPresenter {
    weak private var view: FavoriteNewsViewInputProtocol?
    
    // MARK: - Init
    
    init(view: FavoriteNewsViewInputProtocol) {
        self.view = view
    }
}
extension FavoriteNewsPresenter: FavoriteNewsViewOutputProtocol {
    
}
