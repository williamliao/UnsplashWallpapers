//
//  SettingMainItemCell.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/11/3.
//

import UIKit

class SettingMainItemCell: UICollectionViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: SettingMainItemCell.self)
    }
    
    var label: UILabel!
    var button: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        adaptToUserInterfaceStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingMainItemCell {
    func configure() {
        
        label = UILabel()

       /* let cancel = UIAction(title: "Cancel", attributes: .destructive) { _ in print("cancel") }

        let dark = UIAction(title: "dark", image: UIImage(systemName: "light.max")) { [weak self] _ in
            UserDefaults.standard.setValue(ThemeManager.Theme.dark.rawValue, forKey: SelectedThemeKey)
            UserDefaults.standard.synchronize()
            
            let theme = ThemeManager.Theme.init(rawValue: 0)
            ThemeManager.applyTheme(theme: theme ?? .dark)
            
            self?.button.setTitle("dark", for: .normal)
        }
        
        let light = UIAction(title: "light", image: UIImage(systemName: "light.min")) { [weak self] _ in
            UserDefaults.standard.setValue(ThemeManager.Theme.light.rawValue, forKey: SelectedThemeKey)
            UserDefaults.standard.synchronize()
            
            let theme = ThemeManager.Theme.init(rawValue: 1)
            ThemeManager.applyTheme(theme: theme ?? .light)
            
            self?.button.setTitle("light", for: .normal)
        }
        
        let auto = UIAction(title: "auto", image: UIImage(systemName: "circle.dashed")) { [weak self] _ in
            UserDefaults.standard.setValue(ThemeManager.Theme.auto.rawValue, forKey: SelectedThemeKey)
            UserDefaults.standard.synchronize()
            
            let theme = ThemeManager.Theme.init(rawValue: 2)
            ThemeManager.applyTheme(theme: theme ?? .auto)

            self?.button.setTitle("auto", for: .normal)
        }*/
        
        button = UIButton(type: .custom)
        //button.menu = UIMenu(title: "", children: [dark, light, auto, cancel])
        //button.showsMenuAsPrimaryAction = true

        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        self.addSubview(button)
        
        NSLayoutConstraint.activate([
           
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            label.topAnchor.constraint(equalTo: self.topAnchor),
            
            button.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 5),
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            button.topAnchor.constraint(equalTo: self.topAnchor),
        ])
    }
    
    private func adaptToUserInterfaceStyle() {
            
        let theme = ThemeManager.currentTheme()
        
        if #available(iOS 12.0, *) {
            
            if contentView.traitCollection.userInterfaceStyle == .dark {
                self.backgroundColor = .secondarySystemBackground
            } else {
                self.backgroundColor = .white
            }
        }
        
        button.setTitleColor(theme.titleTextColor, for: .normal)
        label.textColor = theme.titleTextColor
        
        switch theme {
            case .dark:
                button.setTitle("dark", for: .normal)
                
            case .light:
                button.setTitle("light", for: .normal)
                
            case .auto:
                button.setTitle("auto", for: .normal)
                self.backgroundColor = .secondarySystemBackground
        }
        
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Trait collection has already changed
        adaptToUserInterfaceStyle()
    }
}
