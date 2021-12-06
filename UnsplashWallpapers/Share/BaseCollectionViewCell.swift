//
//  BaseCollectionViewCell.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/6.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Trait collection has already changed
        adaptToUserInterfaceStyle()
    }
    
    private func adaptToUserInterfaceStyle() {
        let backgroundColor: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        self.backgroundColor = .clear
        self.contentView.backgroundColor = backgroundColor
    }
}
