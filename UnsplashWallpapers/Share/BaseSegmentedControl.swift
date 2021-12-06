//
//  BaseSegmentedControl.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/6.
//

import UIKit

class BaseSegmentedControl: UISegmentedControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        adaptToUserInterfaceStyle()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        adaptToUserInterfaceStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Trait collection has already changed
        adaptToUserInterfaceStyle()
    }
    
    private func adaptToUserInterfaceStyle() {
        let textColor: UIColor = .gray
        let textSelectedColor: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .gray
        
        let backgroundColor: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        let segmentedSelectedColor: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .gray : .white
        
        self.backgroundColor = backgroundColor
        
        self.backgroundColor = backgroundColor
        self.selectedSegmentTintColor = segmentedSelectedColor

        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor]
        self.setTitleTextAttributes(titleTextAttributes, for:.normal)

        let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: textSelectedColor]
        self.setTitleTextAttributes(titleTextAttributes1, for:.selected)
    }

}
