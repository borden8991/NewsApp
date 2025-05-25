//
//  FavoriteArticle+CoreDataProperties.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 01.05.2025.
//
//

import Foundation
import CoreData


extension FavoriteArticle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteArticle> {
        return NSFetchRequest<FavoriteArticle>(entityName: "FavoriteArticle")
    }

    @NSManaged public var title: String?
    @NSManaged public var desc: String?
    @NSManaged public var url: String?
    @NSManaged public var urlToImage: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var source: String?
}

extension FavoriteArticle : Identifiable { }
