//
//  PhotoListView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import UIKit

enum Section: Int, CaseIterable {
    case main
}

enum CurrentSource: Int, CaseIterable {
    case random
    case nature
    case wallpapers
    case collections
}

class PhotoListView: UIView {
    
    // MARK: - component
    var collectionView: UICollectionView!
    
    var viewModel: PhotoListViewModel
    
    fileprivate var refreshControl: UIRefreshControl!
    
    @available(iOS 13.0, *)
    lazy var dataSource  = makeDataSource()

    @available(iOS 13.0, *)
    lazy var natureDataSource  = makeNatureDataSource()
    
    @available(iOS 13.0, *)
    lazy var wallpapersDataSource  = makeWallpapersDataSource()
    
    @available(iOS 13.0, *)
    lazy var collectionDataSource  = makeCollectionDataSource()
    
    //
    
    var coordinator: MainCoordinator?
    
    var searchButton: UIButton!
    let waringLabel = UILabel()
    
    // MARK:- property
    var firstLoad = true
    var section: CurrentSource = .random
    
    var endRect = CGRect.zero
    var isLoadingNewData = false
    
    let items = ["Random", "Nature", "Wallpapers"]
    lazy var segmentedControl = BaseSegmentedControl(items: items)
    
    var imageLoadQueue: OperationQueue?
    var imageLoadOperations: [IndexPath: ImageLoadOperation] = [:]
    var imageHeightDictionary: [IndexPath: String]?

    init(viewModel: PhotoListViewModel, coordinator: MainCoordinator?) {
        self.viewModel = viewModel
        self.coordinator = viewModel.coordinator
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoListView {
    
    func registerOffLineNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(switchToOfflineView), name: NSNotification.Name(rawValue: "OfflineModeOn"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchOfflineModeOff), name: NSNotification.Name(rawValue: "OfflineModeOff"), object: nil)
    }
    
    func configureCollectionView() {
       
        //let theme = ThemeManager.currentTheme()
        //self.backgroundColor = theme.backgroundColor
        
        let flowLayout = UICollectionViewFlowLayout()
        //flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 300)
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        //let config = UICollectionLayoutListConfiguration(appearance: .plain)
        //let flowLayout = UICollectionViewCompositionalLayout.list(using: config)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        makeDateSourceForCollectionView()
        
        setupRefreshControl()
        createWaringLabel()
        
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
            collectionView.isPrefetchingEnabled = true
            imageLoadQueue = OperationQueue()
            imageLoadOperations = [IndexPath: ImageLoadOperation]()
        }
        
        
        if #available(iOS 13.0, *) {
            collectionView.register(PhotoListCollectionViewCell.self
                                    , forCellWithReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier)
        }
        
        self.addSubview(collectionView)
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Response>()
        Section.allCases.forEach { snapshot.appendSections([$0]) }
        viewModel.respone.value?.forEach { (respone) in
            snapshot.appendItems([respone], toSection: .main)
        }
        dataSource.apply(snapshot, animatingDifferences: true)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 44),
        ])
    }
    
    func makeDateSourceForCollectionView() {
        if #available(iOS 13.0, *) {
           
//            if (!firstLoad) {
//                dataSource = makeDataSource()
//                collectionView.dataSource = dataSource
//                return
//            }
            collectionView.dataSource = dataSource

        } else {
            collectionView.dataSource = self
        }
    }
    
    func createSegmentView() {
        segmentedControl.frame = CGRect.zero
        segmentedControl.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        self.addSubview(segmentedControl)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: self.topAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    @objc func segmentAction(_ segmentedControl: UISegmentedControl) {
        
        imageLoadOperations = [IndexPath: ImageLoadOperation]()
        imageHeightDictionary = [IndexPath: String]()
        
            switch (segmentedControl.selectedSegmentIndex) {
            case 0:
                //print("Random")
                dataSource = makeDataSource()
                collectionView.dataSource = dataSource
                viewModel.reset()
                viewModel.fetchDataWithConcurrency()
                section = .random
                viewModel.segmentedIndex = .random
                
                break // Random
            case 1:
                //print("Nature")
                
                natureDataSource = makeNatureDataSource()
                collectionView.dataSource = natureDataSource
                viewModel.reset()
                viewModel.fetchNature()
                section = .nature
                viewModel.segmentedIndex = .nature
                
                break // Nature
            case 2:
                //print("Wallpapers")
                wallpapersDataSource = makeWallpapersDataSource()
                collectionView.dataSource = wallpapersDataSource
                viewModel.reset()
                viewModel.fetchWallpapers()
                section = .wallpapers
                viewModel.segmentedIndex = .wallpapers
                break // Wallpapers
            default:
                break
            }
    }

    func reloadData() {
        collectionView.reloadData()
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
        self.collectionView.isHidden = hide
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if section == .nature, section == .wallpapers {
            return CGSize(width: collectionView.bounds.size.width, height: 300)
        } else {
            
            let res = viewModel.respone.value
            let height = res?[indexPath.row].height
            let width = res?[indexPath.row].width
            
            if imageHeightDictionary?[indexPath] == "v" {
                return CGSize(width: collectionView.bounds.size.width, height: 600)
            } else if imageHeightDictionary?[indexPath] == "h" {
                return CGSize(width: collectionView.bounds.size.width, height: 300)
            } else {
                if let safeHeight = height, let safeWidth = width {
                    if safeHeight > safeWidth {
                        imageHeightDictionary?[indexPath] = "v"
                        return CGSize(width: collectionView.bounds.size.width, height: 600)
                    } else {
                        imageHeightDictionary?[indexPath] = "h"
                        return CGSize(width: collectionView.bounds.size.width, height: 300)
                    }
                } else {
                    imageHeightDictionary?[indexPath] = "h"
                    return CGSize(width: collectionView.bounds.size.width, height: 300)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - UICollectionViewDiffableDataSource
extension PhotoListView {
    
    @available(iOS 13.0, *)
    private func getDatasource() -> UICollectionViewDiffableDataSource<Section, Response> {
        return dataSource
    }
 
    @available(iOS 13.0, *)
    private func getNatureDatasource() -> UICollectionViewDiffableDataSource<Section, Results> {
        return natureDataSource
    }
    
    @available(iOS 13.0, *)
    private func getWallpapersDatasource() -> UICollectionViewDiffableDataSource<Section, Results> {
        return wallpapersDataSource
    }
    
    @available(iOS 13.0, *)
    private func getCollectionDatasource() -> UICollectionViewDiffableDataSource<Section, CollectionResponse> {
        return collectionDataSource
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Response> {
        
        if #available(iOS 14.0, *) {
            let cellRegistration = UICollectionView.CellRegistration<PhotoListCollectionViewCell, Response> { cell, indexPath, item in
                self.configureCell(cell: cell, respone: item, indexPath: indexPath)
            }
            
            dataSource = UICollectionViewDiffableDataSource<Section, Response>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
                if #available(iOS 14.0, *) {
                    return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: respone)
                }
            }
            
        } else {
            dataSource = UICollectionViewDiffableDataSource<Section, Response>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
                let cell = self.configureCellOld(collectionView: collectionView, respone: respone, indexPath: indexPath)
                return cell
            }
        }
        
        return dataSource
    }
    
    func makeNatureDataSource() -> UICollectionViewDiffableDataSource<Section, Results> {
        
        if #available(iOS 14.0, *) {
            let cellRegistration = UICollectionView.CellRegistration<PhotoListCollectionViewCell, Results> { (cell, indexPath, respone) in
                self.configureTopicCell(cell: cell, respone: respone, indexPath: indexPath)
            }
            
            return UICollectionViewDiffableDataSource<Section, Results>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: respone)
            }
        } else {
            natureDataSource = UICollectionViewDiffableDataSource<Section, Results>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
                let cell = self.configureTopicCellOld(collectionView: collectionView, respone: respone, indexPath: indexPath)
                return cell
            }
        }
        
    }
    
    func makeWallpapersDataSource() -> UICollectionViewDiffableDataSource<Section, Results> {
        
        if #available(iOS 14.0, *) {
            let cellRegistration = UICollectionView.CellRegistration<PhotoListCollectionViewCell, Results> { (cell, indexPath, respone) in
                self.configureTopicCell(cell: cell, respone: respone, indexPath: indexPath)
            }
            
            return UICollectionViewDiffableDataSource<Section, Results>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: respone)
            }
        } else {
            wallpapersDataSource = UICollectionViewDiffableDataSource<Section, Results>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
                let cell = self.configureTopicCellOld(collectionView: collectionView, respone: respone, indexPath: indexPath)
                return cell
            }
        }
    }
    
    func makeCollectionDataSource() -> UICollectionViewDiffableDataSource<Section, CollectionResponse> {
        
        let cellRegistration = UICollectionView.CellRegistration<PhotoListCollectionViewCell, CollectionResponse> { (cell, indexPath, respone) in
            let _ = self.configureCollectionCell(collectionView: self.collectionView, respone: respone, indexPath: indexPath)
        }
        
        return UICollectionViewDiffableDataSource<Section, CollectionResponse>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: respone)
        }
    }
    
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        
        switch section {
            case .random:
            
                guard let respone = viewModel.respone.value else {
                    return
                }
                
                self.randomPhotoDidLoad(respone)

            case .nature:

                guard let topics = viewModel.searchRespone.value else {
                    return
                }
            
                naturePhotoDidLoad(topics.results)

            case .wallpapers:
  
                guard let topics = viewModel.searchRespone.value else {
                    return
                }
            
                wallpaperPhotoDidLoad(topics.results)

            case .collections:
                var snapshot = NSDiffableDataSourceSnapshot<Section, CollectionResponse>()
                collectionDataSource = getCollectionDatasource()
                
                //Append available sections
                Section.allCases.forEach { snapshot.appendSections([$0]) }
                
                //Append annotations to their corresponding sections
                
                guard let collections = viewModel.collectionResponse.value else {
                    return
                }
                
                collections.forEach { (collection) in
                    snapshot.appendItems([collection], toSection: .main)
                }
            
                UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveLinear) {
                    self.collectionDataSource.reloadData(snapshot: snapshot)
                    self.reloadCollectionData()
                } completion: { success in
                
            }
        }
    }
    
    func randomPhotoDidLoad(_ image: [Response]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Response>()
        Section.allCases.forEach { snapshot.appendSections([$0]) }
        //dataSource.apply(snapshot, animatingDifferences: false)

        snapshot.appendItems(image, toSection: .main)

      //  UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions.curveLinear) {
        dataSource.applySnapshot(snapshot, animated: false) {
            self.collectionView.scrollRectToVisible(self.endRect, animated: false)
        }
            //self.reloadCollectionData()
       // } completion: { success in
            
      //  }
    }
    
    func naturePhotoDidLoad(_ image: [Results]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Results>()
        Section.allCases.forEach { snapshot.appendSections([$0]) }
        snapshot.appendItems(image, toSection: .main)

        natureDataSource.applySnapshot(snapshot, animated: false) {
            self.collectionView.scrollRectToVisible(self.endRect, animated: false)
        }
    }
    
    func wallpaperPhotoDidLoad(_ image: [Results]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Results>()
        Section.allCases.forEach { snapshot.appendSections([$0]) }
        snapshot.appendItems(image, toSection: .main)

        wallpapersDataSource.applySnapshot(snapshot, animated: false) {
            self.collectionView.scrollRectToVisible(self.endRect, animated: false)
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension PhotoListView: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        
        switch section {
            case .random:
                
                guard let res = viewModel.respone.value else {
                    return
                }
                
                for indexPath in indexPaths {

                    if let _ = imageLoadOperations[indexPath] {
                        continue
                    }
                    
                    let urls = res[indexPath.row].urls
                    
                    if let url = URL(string: urls.small) {
                        let imageLoadOperation = ImageLoadOperation(imgUrl: url)
                        imageLoadQueue?.addOperation(imageLoadOperation)
                        imageLoadOperations[indexPath] = imageLoadOperation
                    }
                    
                   /* if section == .random {
                        let res = viewModel.respone.value
                        let height = res?[indexPath.row].height
                        let width = res?[indexPath.row].width
                        
                        if let safeHeight = height, let safeWidth = width {
                            
                            if safeHeight > safeWidth {
                                imageHeightDictionary?[indexPath] = "v"
                            } else {
                                imageHeightDictionary?[indexPath] = "h"
                            }
                            
                        } else {
                            imageHeightDictionary?[indexPath] = "h"
                        }
                    } else {
                        let res = viewModel.searchRespone.value
                        let height = res?.results[indexPath.row].height
                        let width = res?.results[indexPath.row].width
                        
                        if let safeHeight = height, let safeWidth = width {
                            
                            if safeHeight > safeWidth {
                                imageHeightDictionary?[indexPath] = "v"
                            } else {
                                imageHeightDictionary?[indexPath] = "h"
                            }
                            
                        } else {
                            imageHeightDictionary?[indexPath] = "h"
                        }
                    }*/
                }

            case .nature, .wallpapers:
               
                guard let res = viewModel.searchRespone.value else {
                    return
                }
                
                for indexPath in indexPaths {
                    if let _ = imageLoadOperations[indexPath] {
                        continue
                    }
                    
                    guard let urls = res.results[indexPath.row].urls else {
                        return
                    }
                    
                    if let url = URL(string: urls.small) {
                        let imageLoadOperation = ImageLoadOperation(imgUrl: url)
                        imageLoadQueue?.addOperation(imageLoadOperation)
                        imageLoadOperations[indexPath] = imageLoadOperation
                    }
                 }
                
            case .collections:
                break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let imageLoadOperation = imageLoadOperations[indexPath] else {
                return
            }
            imageLoadOperation.cancel()
            imageLoadOperations.removeValue(forKey: indexPath)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoListView: UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let count = viewModel.respone.value?.count else {
          return 0
        }
        
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let res = viewModel.respone.value else {
          return UICollectionViewCell()
        }

        guard let cell = self.configureCellOld(collectionView: collectionView, respone: res[indexPath.row], indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        return cell
    }

}

// MARK: - UICollectionViewDelegate
extension PhotoListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if #available(iOS 13.0, *) {
            
            switch section {
                case .random:
                    guard let res = dataSource.itemIdentifier(for: indexPath), let profile = res.user?.profile_image  else {
                        return
                    }
                    
                    let photoInfo = PhotoInfo(id: res.id, title: res.user?.name ?? "", url: res.urls, profile_image: profile, width: CGFloat(res.width), height: CGFloat(res.height))
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                    
                case .nature:
                    guard let res = natureDataSource.itemIdentifier(for: indexPath), let profile = res.user?.profile_image, let urls = res.urls, let width = res.width, let height = res.height else {
                        return
                    }

                    let photoInfo = PhotoInfo(id: res.id, title: res.user?.name ?? "", url: urls, profile_image: profile, width: CGFloat(width), height: CGFloat(height))
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                    
                case .wallpapers:
                    
                    guard let res = wallpapersDataSource.itemIdentifier(for: indexPath), let profile = res.user?.profile_image, let urls = res.urls, let width = res.width, let height = res.height else {
                        return
                    }
                    
                    let photoInfo = PhotoInfo(id: res.id, title: res.user?.name ?? "", url: urls, profile_image: profile, width: CGFloat(width), height: CGFloat(height))
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                case .collections:
                    break
            }
            
        } else {
            
            switch section {
                case .random:
                    guard let res = viewModel.respone.value?[indexPath.row], let profile = res.user?.profile_image else {
                        return
                    }
                    
                    let photoInfo = PhotoInfo(id: res.id, title: res.user?.name ?? "", url: res.urls, profile_image: profile, width: CGFloat(res.width), height: CGFloat(res.height))
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                    
                case .nature:
                    guard let res = viewModel.natureTopic.value?[indexPath.row] else {
                        return
                    }
                    
                    guard let owners = viewModel.natureTopic.value?[indexPath.row].owners else {
                        return
                    }
                    
                    let photoInfo = PhotoInfo(id: res.id, title: "Nature", url: res.preview_photos[indexPath.row].urls, profile_image: owners[indexPath.row].profile_image, width: CGFloat(0), height: CGFloat(0))
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                    
                case .wallpapers:
                    
                    guard let res = viewModel.wallpapersTopic.value?[indexPath.row] else {
                        return
                    }
                    
                    guard let owners = viewModel.natureTopic.value?[indexPath.row].owners else {
                        return
                    }
                    
                    let photoInfo = PhotoInfo(id: res.id, title: "Wallpapers", url: res.preview_photos[indexPath.row].urls, profile_image: owners[indexPath.row].profile_image, width: CGFloat(0), height: CGFloat(0))
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                case .collections:
                    break
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //let lastElement = collectionView.numberOfItems(inSection: indexPath.section) - 1
        let preloadElement = collectionView.numberOfItems(inSection: indexPath.section) - 1
        
        if !viewModel.isLoading.value && indexPath.row == preloadElement {
            
            let theAttributes = collectionView.layoutAttributesForItem(at: indexPath)
            //endRect = theAttributes?.frame ?? CGRect.zero
            
            guard let saveEndRect = theAttributes?.frame else {
                print("someThing wrong with the indexPath \(indexPath)")
                return
            }
            
            endRect = saveEndRect
            
            if #available(iOS 15.0.0, *) {
                viewModel.fetchNextPage()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let dataLoader = imageLoadOperations[indexPath] else {
            return
        }
        dataLoader.cancel()
        imageLoadOperations.removeValue(forKey: indexPath)
    }
    
    private func reloadCollectionData() {
//            self.collectionView.setNeedsLayout()
//            let context = UICollectionViewFlowLayoutInvalidationContext()
//            context.invalidateFlowLayoutAttributes = false
//            self.collectionView.collectionViewLayout.invalidateLayout(with: context)
//            self.collectionView.layoutIfNeeded()

       // UIView.performWithoutAnimation {
            
       // }
        

    }
}

// MARK: - RefreshControll
extension PhotoListView {
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
    }
    
    @objc func refresh() {
        // Call when only refresh is needness.
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }

        if #available(iOS 10.0, *) {
            imageLoadOperations.forEach { $1.cancel() }
        }
        viewModel.reset()
        collectionView.reloadData()
    }
}

// MARK: - Private
extension PhotoListView {
    
    func configureCell(cell: PhotoListCollectionViewCell, respone: Response, indexPath: IndexPath) {
       
        cell.titleLabel.text = respone.user?.name
        
        let updateCellClosure: (UIImage?) -> Void = { [weak self] image in
            guard let self = self else {
              return
            }
            //cell.updateAppearanceFor(emojiRating, animated: true)
            cell.isLoading(isLoading: false)
            cell.showImage(image: image)
            self.imageLoadOperations.removeValue(forKey: indexPath)
        }
        
        if let dataLoader = imageLoadOperations[indexPath] {
           // cell.isLoading(isLoading: true)
            if let image = dataLoader.image {
                cell.isLoading(isLoading: false)
                cell.showImage(image: image)
                imageLoadOperations.removeValue(forKey: indexPath)
            } else {
               // cell.isLoading(isLoading: true)
                dataLoader.completionHandler = updateCellClosure
            }
        } else {
            if let url = URL(string: respone.urls.small) {
                let imageLoadOperation = ImageLoadOperation(imgUrl: url)
                imageLoadQueue?.addOperation(imageLoadOperation)
                imageLoadOperations[indexPath] = imageLoadOperation
                cell.configureImage(with: url)
            }
        }
    }
    
    func configureCellOld(collectionView: UICollectionView, respone: Response, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        cell?.titleLabel.text = respone.user?.name
        
        if let dataLoader = imageLoadOperations[indexPath] {
            cell?.isLoading(isLoading: true)
            if let image = dataLoader.image {
                cell?.isLoading(isLoading: false)
                cell?.showImage(image: image)
            } else {
                cell?.isLoading(isLoading: true)
                dataLoader.completionHandler = { [weak cell] image in
                    cell?.isLoading(isLoading: false)
                    cell?.showImage(image: image)
                }
            }
        } else {
            if let url = URL(string: respone.urls.small) {
                let imageLoadOperation = ImageLoadOperation(imgUrl: url)
                imageLoadQueue?.addOperation(imageLoadOperation)
                imageLoadOperations[indexPath] = imageLoadOperation
                cell?.configureImage(with: url)
            }
        }
        
        return cell
    }
    
    func configureTopicCell(cell: PhotoListCollectionViewCell, respone: Results, indexPath: IndexPath) {
        
        if section == .nature {
            
            cell.titleLabel.text = "Nature"
            
            
        }else if section == .wallpapers {
            
            cell.titleLabel.text = "Wallpapers"
        }
        
        let updateCellClosure: (UIImage?) -> Void = { [weak self] image in
            guard let self = self else {
              return
            }
            //cell.updateAppearanceFor(emojiRating, animated: true)
            cell.isLoading(isLoading: false)
            cell.showImage(image: image)
            self.imageLoadOperations.removeValue(forKey: indexPath)
        }
      
        if let dataLoader = imageLoadOperations[indexPath] {
            //cell.isLoading(isLoading: true)
            if let image = dataLoader.image {
                cell.isLoading(isLoading: false)
                cell.showImage(image: image)
                self.imageLoadOperations.removeValue(forKey: indexPath)
            } else {
                //cell.isLoading(isLoading: true)
                dataLoader.completionHandler = updateCellClosure
            }
        } else {
            
            guard let urls = respone.urls else {
                return
            }
            
            if let url = URL(string: urls.small) {
                let imageLoadOperation = ImageLoadOperation(imgUrl: url)
                imageLoadQueue?.addOperation(imageLoadOperation)
                imageLoadOperations[indexPath] = imageLoadOperation
                cell.configureImage(with: url)
            }
        }

    }
   
    func configureTopicCellOld(collectionView: UICollectionView, respone: Results, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        if section == .nature {
            
            cell?.titleLabel.text = "Nature"
            
            
        }else if section == .wallpapers {
            
            cell?.titleLabel.text = "Wallpapers"
        }
      
        
        if let loader = imageLoadOperations[indexPath] {
            cell?.isLoading(isLoading: true)
            if let image = loader.image {
                cell?.isLoading(isLoading: false)
                cell?.showImage(image: image)
            } else {
                cell?.isLoading(isLoading: true)
                loader.completionHandler = { [weak cell] image in
                    cell?.isLoading(isLoading: false)
                    cell?.showImage(image: image)
                }
            }
        } else {
            
            guard let urls = respone.urls else {
                return cell
            }
            
            if let url = URL(string: urls.small) {
                let imageLoadOperation = ImageLoadOperation(imgUrl: url)
                imageLoadQueue?.addOperation(imageLoadOperation)
                imageLoadOperations[indexPath] = imageLoadOperation
                cell?.configureImage(with: url)
            }
        }

        return cell
    }

    func configureCollectionCell(collectionView: UICollectionView, respone: CollectionResponse, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        cell?.titleLabel.text = respone.user.name
        
        if let url = URL(string: respone.urls.small) {
            cell?.configureImage(with: url)
        }
        
        return cell
    }
}
