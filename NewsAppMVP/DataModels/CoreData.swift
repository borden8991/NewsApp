//
//  CoreData.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 01.05.2025.
//

import UIKit
import CoreData

class CoreDataManager {
    
    private init() {}
    
    // MARK: - Public Properties
    
    static let shared = CoreDataManager()

    public let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FavoriteArticle")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data load error: \(error)")
            }
        }
        return container
    }()

    public var context: NSManagedObjectContext { persistentContainer.viewContext }
    
    public func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
    
    func saveArticle(article: News) {
        
        if isFavorite(article: article) { return }
        
        let favoriteArticle = FavoriteArticle(context: context)
        favoriteArticle.title = article.title
        favoriteArticle.desc = article.description
        favoriteArticle.source = article.source.name
        favoriteArticle.publishedAt = article.publishedAt
        favoriteArticle.urlToImage = article.urlToImage
        favoriteArticle.url = article.url
        
        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
    
    func isFavorite(article: News) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteArticle> = FavoriteArticle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", article.title)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Ошибка проверки избранного:", error)
            return false
        }
    }

    
    func fetchFavorites() -> [FavoriteArticle] {
        let request: NSFetchRequest<FavoriteArticle> = FavoriteArticle.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch favorites: \(error)")
            return []
        }
    }
    
    func deleteAllFavorites() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoriteArticle.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("Failed to delete favorites: \(error)")
        }
    }
    
    func deleteFavorite(article: FavoriteArticle) {
        context.delete(article)
        do {
            try context.save()
        } catch {
            print("Failed to delete favorite: \(error)")
        }
    }
}
