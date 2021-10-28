//
//  SettingView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/8/25.
//

import UIKit

class SettingView: UIView {
    
    enum Section {
        case main
    }
    
    let settingTexts = ["版本資訊", "使用條款", "隱私權條款"]
    let settingSubTexts = ["1.0.0", "", ""]

    var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    var collectionView: UICollectionView! = nil

}

extension SettingView {
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.backgroundColor = .systemBackground
        let config = UICollectionLayoutListConfiguration(appearance:
          .insetGrouped)
        collectionView.collectionViewLayout =
          UICollectionViewCompositionalLayout.list(using: config)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self.dataSource
        self.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func configureDataSource() {
       
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Int> { (cell, indexPath, itemIdentifier) in
            var contentConfiguration = UIListContentConfiguration.valueCell()
            contentConfiguration.text = self.settingTexts[indexPath.row]
            contentConfiguration.textProperties.color = .black

            contentConfiguration.secondaryText = self.settingSubTexts[indexPath.row]
            
            if (indexPath.row != 0) {
                // 1
                let options = UICellAccessory.OutlineDisclosureOptions(style: .header)
                // 2
                let disclosureAccessory = UICellAccessory.outlineDisclosure(options: options)
                // 3
                cell.accessories = [disclosureAccessory]
            }
            
            cell.contentConfiguration = contentConfiguration
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(0..<settingTexts.count))
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
