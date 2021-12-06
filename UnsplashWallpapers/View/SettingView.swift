//
//  SettingView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/8/25.
//

import UIKit

struct SettingItem: Hashable {
    let title: String
    let subTitle: String
    private let id = UUID()

    init(title: String, subTitle: String) {
        self.title = title
        self.subTitle = subTitle
    }
}

class SettingView: UIView {
    
    enum SectionLayoutKind: Int, CaseIterable, Hashable {
        case main
        case about
    }
    
    var section: Section = .main
    
    //let settingTexts = ["Dark Mode", "", ""]
    let settingTexts = [SettingItem(title: "Dark Mode", subTitle: "")]
    let settingAboutTexts = [SettingItem(title: "版本資訊", subTitle: "1.0.0"), SettingItem(title: "使用條款", subTitle: ""), SettingItem(title: "隱私權條款", subTitle: "")]
    //let settingAboutTexts = ["版本資訊", "使用條款", "隱私權條款"]
    //let settingSubTexts = ["1.0.0", "", ""]

    var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, SettingItem>! = nil
    var collectionView: UICollectionView! = nil

}

extension SettingView {
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureLayout())
        collectionView.backgroundColor = .clear
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
    
    func configureLayout() -> UICollectionViewLayout {
      let provider = {(_: Int, layoutEnv: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
        let configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        return .list(using: configuration, layoutEnvironment: layoutEnv)
      }
      return UICollectionViewCompositionalLayout(sectionProvider: provider)
    }
    
    func configureDataSource() {
       
        let configuredMainCell = UICollectionView.CellRegistration<SettingMainItemCell, SettingItem> { (cell, indexPath, itemIdentifier) in
            cell.label.text = itemIdentifier.title

        }
        
        let configuredAboutCell = UICollectionView.CellRegistration<UICollectionViewListCell, SettingItem> { (cell, indexPath, itemIdentifier) in
            var contentConfiguration = UIListContentConfiguration.valueCell()
            
            contentConfiguration.text = itemIdentifier.title
            contentConfiguration.secondaryText = itemIdentifier.subTitle
            
            contentConfiguration.textProperties.color = .label
            contentConfiguration.secondaryTextProperties.color = .systemGray

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
        
        dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, SettingItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: SettingItem) -> UICollectionViewCell? in
            // Return the cell.
            guard let section = SectionLayoutKind(rawValue: indexPath.section) else {
                return nil
            }
            
            switch section {
                case .main:
                    return collectionView.dequeueConfiguredReusableCell(using: configuredMainCell, for: indexPath, item: identifier)
                case .about:
                    return collectionView.dequeueConfiguredReusableCell(using: configuredAboutCell, for: indexPath, item: identifier)
            }
        }
    }
    
    func applyInitialSnapshots() {
        // initial data
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, SettingItem>()
        snapshot.appendSections(SectionLayoutKind.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        var mainSnapshot = NSDiffableDataSourceSectionSnapshot<SettingItem>()
        mainSnapshot.append(settingTexts)
        dataSource.apply(mainSnapshot, to: .main, animatingDifferences: false)
        
        var aboutSnapshot = NSDiffableDataSourceSectionSnapshot<SettingItem>()
        aboutSnapshot.append(settingAboutTexts)
        dataSource.apply(aboutSnapshot, to: .about, animatingDifferences: false)
    }
}
