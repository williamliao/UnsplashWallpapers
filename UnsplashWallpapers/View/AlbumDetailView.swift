//
//  AlbumDetailView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import UIKit

class AlbumDetailView: UIView {

    let viewModel: AlbumDetailViewModel!
    
    var coordinator: MainCoordinator?
    
    init(viewModel: AlbumDetailViewModel, coordinator: MainCoordinator?) {
        self.viewModel = viewModel
        self.coordinator = viewModel.coordinator
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Section {
      case albumBody
    }

    var albumDetailCollectionView: UICollectionView! = nil

    var albumURL: URL?
    
    @available(iOS 13.0, *)
    lazy var dataSource  = makeDataSource()
    
}

extension AlbumDetailView {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: generateLayout())
        self.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(AlbumPhotoItemCell.self, forCellWithReuseIdentifier: AlbumPhotoItemCell.reuseIdentifier)
       
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
        albumDetailCollectionView = collectionView
        dataSource = makeDataSource()
        collectionView.dataSource = dataSource
    }
    
    func generateLayout() -> UICollectionViewLayout {
    
      // Full
      let fullPhotoItem = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalWidth(2/3)))
      fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

      // Main with pair
      let mainItem = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(2/3),
          heightDimension: .fractionalHeight(1.0)))
      mainItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

      let pairItem = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalHeight(0.5)))
      pairItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
      
        let trailingGroup = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1/3),
          heightDimension: .fractionalHeight(1.0)),
        subitem: pairItem,
        count: 2)

      let mainWithPairGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalWidth(4/9)),
        subitems: [mainItem, trailingGroup])

      // Triplet
      let tripletItem = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1/3),
          heightDimension: .fractionalHeight(1.0)))
      tripletItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

      let tripletGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalWidth(2/9)),
        subitems: [tripletItem, tripletItem, tripletItem])

      // Reversed main with pair
      let mainWithPairReversedGroup = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalWidth(4/9)),
        subitems: [trailingGroup, mainItem])

      let nestedGroup = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1.0),
          heightDimension: .fractionalWidth(16/9)),
        subitems: [fullPhotoItem, mainWithPairGroup, tripletGroup, mainWithPairReversedGroup])

      let section = NSCollectionLayoutSection(group: nestedGroup)
      let layout = UICollectionViewCompositionalLayout(section: section)
      return layout
    }
    
    func configureDataSource() {
        dataSource = makeDataSource()
        
        let snapshot = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, AlbumDetailItem> {
      var snapshot = NSDiffableDataSourceSnapshot<Section, AlbumDetailItem>()
      snapshot.appendSections([Section.albumBody])
   
        self.viewModel.detailRespone.value.forEach { (detail) in
            snapshot.appendItems([detail], toSection: .albumBody)
        }
        
      return snapshot
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, AlbumDetailItem> {
        
        return UICollectionViewDiffableDataSource<Section, AlbumDetailItem>(collectionView: albumDetailCollectionView) { (collectionView, indexPath, albumDetailItem) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
              withReuseIdentifier: AlbumPhotoItemCell.reuseIdentifier,
              for: indexPath) as? AlbumPhotoItemCell else { fatalError("Could not create new cell") }
            cell.photoURL = albumDetailItem.thumbnailURL
            return cell
            
        }
    }
}

extension AlbumDetailView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
    let photoInfo = PhotoInfo(id: item.identifier, title: item.title, url: item.urls, profile_image: item.profile_image)
    coordinator?.goToDetailView(photoInfo: photoInfo)
  }
}
