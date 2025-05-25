//
//  ThemeManager.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 24.05.2025.
//

import UIKit

enum Theme: String {
    case light
    case dark
}

class ThemeManager {
    static let shared = ThemeManager()

    var currentTheme: Theme {
        get {
            if let stored = UserDefaults.standard.string(forKey: "theme"),
               let theme = Theme(rawValue: stored) {
                return theme
            }
            return .light
        }
    }

    func applyTheme(_ theme: Theme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: "theme")

        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first {
            window.overrideUserInterfaceStyle = theme == .dark ? .dark : .light
        }
    }
}
