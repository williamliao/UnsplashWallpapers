//
//  AlbumsView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import UIKit

class AlbumsView: UIView {
    static let sectionHeaderElementKind = "section-header-element-kind"
    
    let viewModel: AlbumsViewModel!
    
    var coordinator: MainCoordinator?
    
    init(viewModel: AlbumsViewModel, coordinator: MainCoordinator?) {
        self.viewModel = viewModel
        self.coordinator = viewModel.coordinator
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Section: String, CaseIterable {
        case featuredAlbums = "Featured Albums"
        case sharedAlbums = "Shared Albums"
        case myAlbums = "My Albums"
    }

    var albumsCollectionView: UICollectionView! = nil
    let waringLabel = UILabel()
    
    var networkConnectivityManager: NetworkConnectivityManager!
    
    @available(iOS 13.0, *)
    lazy var dataSource  = makeDataSource()
    
    deinit {
        networkConnectivityManager.close()
    }
}

extension AlbumsView {
    func configureCollectionView() {
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: generateLayout())
        self.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(AlbumItemCell.self, forCellWithReuseIdentifier: AlbumItemCell.reuseIdentifier)
        collectionView.register(FeaturedAlbumItemCell.self, forCellWithReuseIdentifier: FeaturedAlbumItemCell.reuseIdentifier)
        collectionView.register(SharedAlbumItemCell.self, forCellWithReuseIdentifier: SharedAlbumItemCell.reuseIdentifier)
        collectionView.register(
            AlbumHeaderCollectionReusableView.self,
          forSupplementaryViewOfKind: AlbumsView.sectionHeaderElementKind,
          withReuseIdentifier: AlbumHeaderCollectionReusableView.reuseIdentifier)
       
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
        albumsCollectionView = collectionView
        dataSource = makeDataSource()
        collectionView.dataSource = dataSource
        
        createWaringLabel()
        
        startMonitor()
    }
    
    func configureDataSource() {
      dataSource = UICollectionViewDiffableDataSource
        <Section, AlbumItem>(collectionView: albumsCollectionView) {
          (collectionView: UICollectionView, indexPath: IndexPath, albumItem: AlbumItem) -> UICollectionViewCell? in
        
        if (albumItem.albumTitle.count == 0) {
            return UICollectionViewCell()
        }
        
          let sectionType = Section.allCases[indexPath.section]
          switch sectionType {
          case .featuredAlbums:
            let cell = self.configureFeaturedAlbumItemCell(collectionView: collectionView, albumItem: albumItem, indexPath: indexPath)
            return cell

          case .sharedAlbums:
            let cell = self.configureSharedAlbumItemCell(collectionView: collectionView, albumItem: albumItem, indexPath: indexPath)
            return cell

          case .myAlbums:
            let cell = self.configureAllAlbumCell(collectionView: collectionView, albumItem: albumItem, indexPath: indexPath)
            return cell

          }
      }
      
        dataSource.supplementaryViewProvider = { (
          collectionView: UICollectionView,
          kind: String,
          indexPath: IndexPath) -> UICollectionReusableView? in

          guard let supplementaryView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: AlbumHeaderCollectionReusableView.reuseIdentifier,
            for: indexPath) as? AlbumHeaderCollectionReusableView else { fatalError("Cannot create header view") }

          supplementaryView.label.text = Section.allCases[indexPath.section].rawValue
          return supplementaryView
        }

      let snapshot = snapshotForCurrentState()
      dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, AlbumItem> {
        
        return UICollectionViewDiffableDataSource<Section, AlbumItem>(collectionView: albumsCollectionView) { (collectionView, indexPath, albumItem) -> UICollectionViewCell? in
           
            let sectionType = Section.allCases[indexPath.section]
            switch sectionType {
            case .featuredAlbums:
                let cell = self.configureFeaturedAlbumItemCell(collectionView: collectionView, albumItem: albumItem, indexPath: indexPath)
                return cell

            case .sharedAlbums:
                let cell = self.configureSharedAlbumItemCell(collectionView: collectionView, albumItem: albumItem, indexPath: indexPath)
                return cell

            case .myAlbums:
                let cell = self.configureAllAlbumCell(collectionView: collectionView, albumItem: albumItem, indexPath: indexPath)
                return cell
            }
        }
        
        
    }
   
    func generateLayout() -> UICollectionViewLayout {
      let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
        layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
        let isWideView = layoutEnvironment.container.effectiveContentSize.width > 500
        
        let sectionLayoutKind = Section.allCases[sectionIndex]
        switch (sectionLayoutKind) {
        case .featuredAlbums: return self.generateFeaturedAlbumsLayout(isWide: isWideView)
        case .sharedAlbums: return self.generateSharedlbumsLayout()
        case .myAlbums: return self.generateMyAlbumsLayout(isWide: isWideView)
        }
      }
      return layout
    }

    func generateFeaturedAlbumsLayout(isWide: Bool) -> NSCollectionLayoutSection {
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                            heightDimension: .fractionalWidth(2/3))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)

      // Show one item plus peek on narrow screens, two items plus peek on wider screens
      let groupFractionalWidth = isWide ? 0.475 : 0.95
      let groupFractionalHeight: Float = isWide ? 1/3 : 2/3
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(CGFloat(groupFractionalWidth)),
        heightDimension: .fractionalWidth(CGFloat(groupFractionalHeight)))
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
      group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

      let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(44))
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: AlbumsView.sectionHeaderElementKind, alignment: .top)

      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [sectionHeader]
      section.orthogonalScrollingBehavior = .groupPaging

      return section
    }

    func generateSharedlbumsLayout() -> NSCollectionLayoutSection {
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalWidth(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)

      let groupSize = NSCollectionLayoutSize(
        widthDimension: .absolute(140),
        heightDimension: .absolute(186))
      let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
      group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

      let headerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(44))
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: AlbumsView.sectionHeaderElementKind,
        alignment: .top)

      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [sectionHeader]
      section.orthogonalScrollingBehavior = .groupPaging

      return section
    }

    func generateMyAlbumsLayout(isWide: Bool) -> NSCollectionLayoutSection {
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

      let groupHeight = NSCollectionLayoutDimension.fractionalWidth(isWide ? 0.25 : 0.5)
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: groupHeight)
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: isWide ? 4 : 2)

      let headerSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .estimated(44))
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: headerSize,
        elementKind: AlbumsView.sectionHeaderElementKind,
        alignment: .top)

      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [sectionHeader]

      return section
    }

    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<Section, AlbumItem> {

        var snapshot = NSDiffableDataSourceSnapshot<Section, AlbumItem>()
        snapshot.appendSections([Section.featuredAlbums])

        snapshot.appendSections([Section.sharedAlbums])

        snapshot.appendSections([Section.myAlbums])
        
        self.viewModel.allAlbumsRespone.value.forEach { (respone) in
            snapshot.appendItems([respone], toSection: .myAlbums)
        }
        
        self.viewModel.featuredAlbumsRespone.value.forEach { (respone) in
            snapshot.appendItems([respone], toSection: .featuredAlbums)
        }
        
        self.viewModel.sharedAlbumsRespone.value.forEach { (respone) in
            snapshot.appendItems([respone], toSection: .sharedAlbums)
        }
        
        return snapshot
    }
}

extension AlbumsView {
    
    func configureAllAlbumCell(collectionView: UICollectionView, albumItem: AlbumItem, indexPath: IndexPath) -> AlbumItemCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumItemCell.reuseIdentifier, for: indexPath) as? AlbumItemCell

        cell?.title = albumItem.albumTitle
        cell?.featuredPhotoURL = albumItem.albumURL
        return cell
    }
    
    func configureSharedAlbumItemCell(collectionView: UICollectionView, albumItem: AlbumItem, indexPath: IndexPath) -> SharedAlbumItemCell? {
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: SharedAlbumItemCell.reuseIdentifier,
          for: indexPath) as? SharedAlbumItemCell else { fatalError("Could not create new cell") }

        cell.title = albumItem.albumTitle
        cell.featuredPhotoURL = albumItem.albumURL
        cell.userProfileURL = albumItem.ownerURL
        cell.ownerLabel.text = albumItem.ownerTitle
        cell.titleLabel.text = albumItem.albumTitle
        return cell
    }
    
    func configureFeaturedAlbumItemCell(collectionView: UICollectionView, albumItem: AlbumItem, indexPath: IndexPath) -> FeaturedAlbumItemCell? {
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: FeaturedAlbumItemCell.reuseIdentifier,
          for: indexPath) as? FeaturedAlbumItemCell else { fatalError("Could not create new cell") }
        cell.title = albumItem.albumTitle
        cell.featuredPhotoURL = albumItem.albumURL
        cell.totalNumberOfImages = albumItem.imageItems.count
        cell.isLandscape = albumItem.isLandscape
        return cell
    }
}

extension AlbumsView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
    coordinator?.goToAlbumDetailView(albumDetailItems: item.imageItems)
  }
}

extension AlbumsView {
    func startMonitor() {
        networkConnectivityManager = NetworkConnectivityManager()
        networkConnectivityManager.start()
        
        networkConnectivityManager.monitorHandler { [weak self] (isOffline) in
            if (isOffline) {
                self?.switchToOfflineView()
            } else {
                self?.switchOfflineModeOff()
            }
        }
    }
    
    func createWaringLabel() {
        waringLabel.text = "You Are OffLine Check Out Your Internet Connection"
        waringLabel.font = UIFont.systemFont(ofSize: 32)
        waringLabel.numberOfLines = 0
        waringLabel.lineBreakMode = .byTruncatingTail
        waringLabel.textColor = .label
        waringLabel.textAlignment = .center
        waringLabel.translatesAutoresizingMaskIntoConstraints = false
        waringLabel.isHidden = true
        self.addSubview(waringLabel)
        
        NSLayoutConstraint.activate([
            waringLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            waringLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            waringLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            waringLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            waringLabel.heightAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    @objc func switchToOfflineView() {
        DispatchQueue.main.async {
            self.hideCollectionView(hide: true)
            self.waringLabel.isHidden = false
        }
    }
    
    @objc func switchOfflineModeOff() {
        DispatchQueue.main.async {
            self.hideCollectionView(hide: false)
            self.waringLabel.isHidden = true
        }
    }
    
    func hideCollectionView(hide: Bool) {
        self.albumsCollectionView.isHidden = hide
    }
}
