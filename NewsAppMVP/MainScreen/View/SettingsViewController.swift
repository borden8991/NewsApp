//
//  SettingsViewController.swift
//  NewsAppMVP
//
//  Created by Denis Borovoi on 24.05.2025.
//

import Foundation

import UIKit

class SettingsViewController: UITableViewController {

    enum SettingsSection: Int, CaseIterable {
        case appearance
        case about
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch SettingsSection(rawValue: section)! {
        case .appearance:
            return 1
        case .about:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch SettingsSection(rawValue: section)! {
        case .appearance:
            return "Appearance"
        case .about:
            return "About the app"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch SettingsSection(rawValue: indexPath.section)! {
        case .appearance:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = "Dark mode"
            let themeSwitch = UISwitch()
            themeSwitch.isOn = ThemeManager.shared.currentTheme == .dark
            themeSwitch.addTarget(self, action: #selector(themeSwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = themeSwitch
            return cell

        case .about:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                cell.textLabel?.text = "Version: \(version)"
            } else {
                cell.textLabel?.text = "Version: unknown"
            }
            cell.selectionStyle = .none
            return cell
        }
    }

    @objc private func themeSwitchChanged(_ sender: UISwitch) {
        let selectedTheme: Theme = sender.isOn ? .dark : .light
        ThemeManager.shared.applyTheme(selectedTheme)
    }
}
