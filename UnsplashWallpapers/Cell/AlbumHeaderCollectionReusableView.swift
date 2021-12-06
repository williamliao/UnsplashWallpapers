//
//  AlbumHeaderCollectionReusableView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import UIKit

class AlbumHeaderCollectionReusableView: UICollectionReusableView {
    
    static var reuseIdentifier: String {
        return String(describing: AlbumHeaderCollectionReusableView.self)
    }

    let label = UILabel()

    override init(frame: CGRect) {
    super.init(frame: frame)
        configure()
        adaptToUserInterfaceStyle()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension AlbumHeaderCollectionReusableView {
    func configure() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true

        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
          label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
          label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
          label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
          label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
        ])
        label.font = UIFont.preferredFont(forTextStyle: .title3)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Trait collection has already changed
        adaptToUserInterfaceStyle()
    }
    
    private func adaptToUserInterfaceStyle() {
        let textColor: UIColor = UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
        label.textColor = textColor;
    }
}
