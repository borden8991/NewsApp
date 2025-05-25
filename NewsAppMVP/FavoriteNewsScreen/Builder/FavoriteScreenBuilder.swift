//
//  FavoriteScreenBuilder.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 27.04.2025.
//

import UIKit

final class FavoriteScreenBuilder {
    class func createFavoriteNewsScreen() -> UIViewController {
        let view = FavoriteNewsViewController()
        let presenter = FavoriteNewsPresenter(view: view)
        view.presenter = presenter
        print("created favorite news screen")
        return view
    }
}
