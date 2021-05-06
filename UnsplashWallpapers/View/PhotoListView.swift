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
    
    // MARK:- property
    var firstLoad = true
    var section: CurrentSource = .random
    
    var currentIndex = 0
    var offsetY = 0
    var endRect = CGRect.zero
    
    let items = ["Random", "Nature", "Wallpapers"]
    lazy var segmentedControl = UISegmentedControl(items: items)
    
    var imageLoadQueue: OperationQueue?
    var imageLoadOperations: [IndexPath: ImageLoadOperation]?
    
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
    
    func configureCollectionView(Add to: UIView) {
       
        to.backgroundColor = .systemBackground
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: 300)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        makeDateSourceForCollectionView()
        
        setupRefreshControl()
        
        if #available(iOS 10.0, *) {
            collectionView.prefetchDataSource = self
            imageLoadQueue = OperationQueue()
            imageLoadOperations = [IndexPath: ImageLoadOperation]()
        }
        
        collectionView.register(PhotoListCollectionViewCell.self
                                , forCellWithReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier)
        
        to.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: to.safeAreaLayoutGuide.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: to.safeAreaLayoutGuide.topAnchor, constant: 44),
        ])
    }
    
    func makeDateSourceForCollectionView() {
        if #available(iOS 13.0, *) {
           
            if (!firstLoad) {
                dataSource = makeDataSource()
                collectionView.dataSource = dataSource
                return
            }
            
            collectionView.dataSource = dataSource
            firstLoad = false
            
        } else {
            collectionView.dataSource = self
        }
    }
    
    func createSegmentView(view : UIView) {
        segmentedControl.frame = CGRect.zero
        segmentedControl.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        view.addSubview(segmentedControl)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    @objc func segmentAction(_ segmentedControl: UISegmentedControl) {
            switch (segmentedControl.selectedSegmentIndex) {
            case 0:
                //print("Random")
                dataSource = makeDataSource()
                collectionView.dataSource = dataSource
                viewModel.fetchData()
                viewModel.reset()
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
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PhotoListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if section == .nature, section == .wallpapers {
            let res = viewModel.searchRespone.value
            let height = res?.results[indexPath.row].height
            let width = res?.results[indexPath.row].width
            
            if let safeHeight = height, let safeWidth = width {
                
                if safeHeight > safeWidth {
                    let resizeH = CGFloat(safeHeight) / 8
                    
                    let resizeHeight: CGFloat = CGFloat(resizeH)
                    
                    return CGSize(width: collectionView.bounds.size.width, height: resizeHeight)
                } else {
                    return CGSize(width: collectionView.bounds.size.width, height: 300)
                }
                
            } else {
                return CGSize(width: collectionView.bounds.size.width, height: 300)
            }
        } else {
            let res = viewModel.respone.value
            let height = res?[indexPath.row].height
            let width = res?[indexPath.row].width
            
            if let safeHeight = height, let safeWidth = width {
                
                if safeHeight > safeWidth {
                    let resizeH = CGFloat(safeHeight) / 8
                    
                    let resizeHeight: CGFloat = CGFloat(resizeH)
                    
                    return CGSize(width: collectionView.bounds.size.width, height: resizeHeight)
                } else {
                    return CGSize(width: collectionView.bounds.size.width, height: 300)
                }
                
            } else {
                return CGSize(width: collectionView.bounds.size.width, height: 300)
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
        
        return UICollectionViewDiffableDataSource<Section, Response>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            let cell = self.configureCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    func makeNatureDataSource() -> UICollectionViewDiffableDataSource<Section, Results> {
        
        return UICollectionViewDiffableDataSource<Section, Results>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            let cell = self.configureTopicCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    func makeWallpapersDataSource() -> UICollectionViewDiffableDataSource<Section, Results> {

        return UICollectionViewDiffableDataSource<Section, Results>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            let cell = self.configureTopicCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    func makeCollectionDataSource() -> UICollectionViewDiffableDataSource<Section, CollectionResponse> {
        
        return UICollectionViewDiffableDataSource<Section, CollectionResponse>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            let cell = self.configureCollectionCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        
        switch section {
            case .random:
                var snapshot = NSDiffableDataSourceSnapshot<Section, Response>()
                if (!firstLoad) {
                    dataSource = makeDataSource()
                } else {
                    dataSource = getDatasource()
                }
                
                //Append available sections
                Section.allCases.forEach { snapshot.appendSections([$0]) }
                
                //Append annotations to their corresponding sections
                
                viewModel.respone.value?.forEach { (respone) in
                    snapshot.appendItems([respone], toSection: .main)
                }
                
                //Force the update on the main thread to silence a warning about collectionView not being in the hierarchy!
                DispatchQueue.main.async {
                    self.collectionView.setNeedsLayout()
                    self.dataSource.apply(snapshot, animatingDifferences: false)
                    self.reloadCollectionData()
                }
                
            case .nature:
                var snapshot = NSDiffableDataSourceSnapshot<Section, Results>()
                natureDataSource.apply(snapshot, animatingDifferences: false)
                if (!firstLoad) {
                    natureDataSource = makeNatureDataSource()
                } else {
                    natureDataSource = getNatureDatasource()
                }
                
                //Append available sections
                Section.allCases.forEach { snapshot.appendSections([$0]) }
                
                //Append annotations to their corresponding sections
                
                guard let topics = viewModel.searchRespone.value else {
                    return
                }
                
                topics.results.forEach { (result) in
                    snapshot.appendItems([result], toSection: .main)
                }
                
                //Force the update on the main thread to silence a warning about collectionView not being in the hierarchy!
                DispatchQueue.main.async {
                    self.collectionView.setNeedsLayout()
                    self.natureDataSource.apply(snapshot, animatingDifferences: false)
                    self.reloadCollectionData()
                }
                
            case .wallpapers:
                var snapshot = NSDiffableDataSourceSnapshot<Section, Results>()
                wallpapersDataSource.apply(snapshot, animatingDifferences: false)
                if (!firstLoad) {
                    wallpapersDataSource = makeWallpapersDataSource()
                } else {
                    wallpapersDataSource = getWallpapersDatasource()
                }
                                //Append available sections
                Section.allCases.forEach { snapshot.appendSections([$0]) }
                
                //Append annotations to their corresponding sections
                
                guard let topics = viewModel.searchRespone.value else {
                    return
                }
                
                topics.results.forEach { (result) in
                    
                    snapshot.appendItems([result], toSection: .main)
                }
                
                //Force the update on the main thread to silence a warning about collectionView not being in the hierarchy!
                DispatchQueue.main.async {
                    self.collectionView.setNeedsLayout()
                    self.wallpapersDataSource.apply(snapshot, animatingDifferences: false)
                    self.reloadCollectionData()
                    
                }
            case .collections:
                var snapshot = NSDiffableDataSourceSnapshot<Section, CollectionResponse>()
                if (!firstLoad) {
                    collectionDataSource = makeCollectionDataSource()
                } else {
                    collectionDataSource = getCollectionDatasource()
                }
                
                //Append available sections
                Section.allCases.forEach { snapshot.appendSections([$0]) }
                
                //Append annotations to their corresponding sections
                
                guard let collections = viewModel.collectionResponse.value else {
                    return
                }
                
                collections.forEach { (collection) in
                    snapshot.appendItems([collection], toSection: .main)
                }
                
                //Force the update on the main thread to silence a warning about collectionView not being in the hierarchy!
                DispatchQueue.main.async {
                    self.collectionDataSource.apply(snapshot, animatingDifferences: false)
                    self.reloadCollectionData()
                    
                }
                
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
                    
                    if let _ = imageLoadOperations?[indexPath] {
                        return
                    }
                    
                    let urls = res[indexPath.row].urls
                    
                    if let url = URL(string: urls.small) {
                        let imageLoadOperation = ImageLoadOperation(imgUrl: url)
                        imageLoadQueue?.addOperation(imageLoadOperation)
                        imageLoadOperations?[indexPath] = imageLoadOperation
                    }
                }

            case .nature, .wallpapers:
                
                guard let res = viewModel.searchRespone.value else {
                    return
                }
                
                for indexPath in indexPaths {
                    if let _ = imageLoadOperations?[indexPath] {
                        return
                    }
                    
                    guard let urls = res.results[indexPath.row].urls else {
                        return
                    }
                    
                    if let url = URL(string: urls.small) {
                        let imageLoadOperation = ImageLoadOperation(imgUrl: url)
                        imageLoadQueue?.addOperation(imageLoadOperation)
                        imageLoadOperations?[indexPath] = imageLoadOperation
                    }
                }
                
            case .collections:
                break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let imageLoadOperation = imageLoadOperations?[indexPath] else {
                return
            }
            imageLoadOperation.cancel()
            _ = imageLoadOperations?.removeValue(forKey: indexPath)
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
        
        guard let cell = self.configureCell(collectionView: collectionView, respone: res[indexPath.row], indexPath: indexPath) else {
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
 
        let lastElement = collectionView.numberOfItems(inSection: indexPath.section) - 1
        if !viewModel.isLoading.value && indexPath.row == lastElement {
         
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: collectionView.bounds.width, height: CGFloat(44))
            spinner.color = traitCollection.userInterfaceStyle == .light ? UIColor.black : UIColor.white
            
            currentIndex = lastElement
            
            let lastIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
            let theAttributes = collectionView.layoutAttributesForItem(at: lastIndexPath)
            
            endRect = theAttributes?.frame ?? CGRect.zero
            viewModel.fetchNextPage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let imageLoadOperation = imageLoadOperations?[indexPath] else {
            return
        }
        imageLoadOperation.cancel()
        _ = imageLoadOperations?.removeValue(forKey: indexPath)
    }
    
    private func reloadCollectionData() {
       
        self.collectionView.layoutIfNeeded()
       
        UIView.animate(withDuration: 0.25) {
            self.collectionView.scrollRectToVisible(self.endRect, animated: false)
        }
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
            imageLoadOperations?.forEach { $1.cancel() }
        }
        viewModel.reset()
        collectionView.reloadData()
    }
}

// MARK: - Private
extension PhotoListView {
    
    func configureCell(collectionView: UICollectionView, respone: Response, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        cell?.titleLabel.text = respone.user?.name
        
        if let loader = imageLoadOperations?[indexPath] {
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
            if let url = URL(string: respone.urls.small) {
                let imageLoadOperation = ImageLoadOperation(imgUrl: url)
                imageLoadQueue?.addOperation(imageLoadOperation)
                imageLoadOperations?[indexPath] = imageLoadOperation
                cell?.configureImage(with: url)
            }
        }
        
        return cell
    }
   
    func configureTopicCell(collectionView: UICollectionView, respone: Results, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        if section == .nature {
            
            cell?.titleLabel.text = "Nature"
            
            
        }else if section == .wallpapers {
            
            cell?.titleLabel.text = "Wallpapers"
        }
        
        if let loader = imageLoadOperations?[indexPath] {
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
                imageLoadOperations?[indexPath] = imageLoadOperation
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
