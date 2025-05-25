//
//  MainScreenBuilder.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 27.04.2025.
//

import UIKit

final class MainScreenBuilder {
    class func createMainScreen() -> UIViewController {
        let view = ViewController()
        let service = NewsService()
        let presenter = MainPresenter(view: view, service: service)
        view.presenter = presenter
        print("created main screen")
        return view
    }
}
