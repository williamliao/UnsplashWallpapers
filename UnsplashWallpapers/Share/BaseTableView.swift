//
//  BaseTableView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/12/6.
//

import UIKit

class BaseTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
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
        let backgroundColor: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
        self.backgroundColor = backgroundColor
    }

}
