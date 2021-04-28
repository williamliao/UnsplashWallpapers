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
    
    var currentIndex = 0;
    //var currentOffset:CGPoint = CGPoint.zero;
    var previousContentHeight:CGFloat = 0.0
    var previousContentOffset:CGFloat = 0.0
    
    let items = ["Random", "Nature", "Wallpapers"]
    lazy var segmentedControl = UISegmentedControl(items: items)
    
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
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.estimatedItemSize = .zero

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.delegate = self
        //collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        makeDateSourceForCollectionView()
        
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
                print("Random")
                dataSource = makeDataSource()
                collectionView.dataSource = dataSource
                viewModel.fetchData()
                section = .random
                
                break // Random
            case 1:
                print("Nature")
                
                natureDataSource = makeNatureDataSource()
                collectionView.dataSource = natureDataSource
                
                viewModel.fetchNature()
                section = .nature
                
                break // Nature
            case 2:
                print("Wallpapers")
                wallpapersDataSource = makeWallpapersDataSource()
                collectionView.dataSource = wallpapersDataSource
                viewModel.fetchWallpapers()
                section = .wallpapers
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

       /* let cellsPerRow = 1
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize(width: 0, height: 0) }
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: 300)*/
       
        return CGSize(width: collectionView.bounds.size.width, height: 300)
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
    private func getNatureDatasource() -> UICollectionViewDiffableDataSource<Section, Preview_Photos> {
        return natureDataSource
    }
    
    @available(iOS 13.0, *)
    private func getWallpapersDatasource() -> UICollectionViewDiffableDataSource<Section, Preview_Photos> {
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
    
    func makeNatureDataSource() -> UICollectionViewDiffableDataSource<Section, Preview_Photos> {
        
        return UICollectionViewDiffableDataSource<Section, Preview_Photos>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            let cell = self.configureTopicCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    func makeWallpapersDataSource() -> UICollectionViewDiffableDataSource<Section, Preview_Photos> {

        return UICollectionViewDiffableDataSource<Section, Preview_Photos>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
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
                    self.dataSource.apply(snapshot, animatingDifferences: false)
                    
                    if (self.currentIndex > 0) {
                        UIView.animate(withDuration: 0.25) {
                            self.collectionView.scrollToItem(at: IndexPath(row: self.currentIndex, section: Section.main.rawValue), at: .bottom, animated: false)
                        }
                    }
                    
                }
                
            case .nature:
                var snapshot = NSDiffableDataSourceSnapshot<Section, Preview_Photos>()
                natureDataSource.apply(snapshot, animatingDifferences: false)
                if (!firstLoad) {
                    natureDataSource = makeNatureDataSource()
                } else {
                    natureDataSource = getNatureDatasource()
                }
                
                //Append available sections
                Section.allCases.forEach { snapshot.appendSections([$0]) }
                
                //Append annotations to their corresponding sections
                
                guard let topics = viewModel.natureTopic.value else {
                    return
                }
                
                topics.forEach { (topic) in
                    snapshot.appendItems(topic.preview_photos, toSection: .main)
                }
                
                //Force the update on the main thread to silence a warning about collectionView not being in the hierarchy!
                DispatchQueue.main.async {
                    self.natureDataSource.apply(snapshot, animatingDifferences: false)
                    
                    if (self.currentIndex > 0) {
                        UIView.animate(withDuration: 0.25) {
                            self.collectionView.scrollToItem(at: IndexPath(row: self.currentIndex, section: self.section.rawValue), at: .bottom, animated: false)
                        }
                    }
                    
                }
                
            case .wallpapers:
                var snapshot = NSDiffableDataSourceSnapshot<Section, Preview_Photos>()
                wallpapersDataSource.apply(snapshot, animatingDifferences: false)
                if (!firstLoad) {
                    wallpapersDataSource = makeWallpapersDataSource()
                } else {
                    wallpapersDataSource = getWallpapersDatasource()
                }
                
                //Append available sections
                Section.allCases.forEach { snapshot.appendSections([$0]) }
                
                //Append annotations to their corresponding sections
                
                guard let topics = viewModel.wallpapersTopic.value else {
                    return
                }
                
                topics.forEach { (topic) in
                    snapshot.appendItems(topic.preview_photos, toSection: .main)
                }
                
                //Force the update on the main thread to silence a warning about collectionView not being in the hierarchy!
                DispatchQueue.main.async {
                    self.wallpapersDataSource.apply(snapshot, animatingDifferences: false)
                    
                    if (self.currentIndex > 0) {
                        UIView.animate(withDuration: 0.25) {
                            self.collectionView.scrollToItem(at: IndexPath(row: self.currentIndex, section: self.section.rawValue), at: .bottom, animated: false)
                        }
                    }
                    
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
                    
                    if (self.currentIndex > 0) {
                        UIView.animate(withDuration: 0.25) {
                            self.collectionView.scrollToItem(at: IndexPath(row: self.currentIndex, section: self.section.rawValue), at: .bottom, animated: false)
                        }
                    }
                    
                }
                
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
                    
                    let photoInfo = PhotoInfo(title: res.user?.name ?? "", url: res.urls, profile_image: profile)
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                    
                case .nature:
                    guard let res = natureDataSource.itemIdentifier(for: indexPath) else {
                        return
                    }
                    
                    guard let owners = viewModel.natureTopic.value?[indexPath.row].owners else {
                        return
                    }
                    
                    let photoInfo = PhotoInfo(title: "Nature", url: res.urls, profile_image: owners[indexPath.row].profile_image)
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                    
                case .wallpapers:
                    
                    guard let res = wallpapersDataSource.itemIdentifier(for: indexPath) else {
                        return
                    }
                    
                    guard let owners = viewModel.natureTopic.value?[indexPath.row].owners else {
                        return
                    }
                    
                    let photoInfo = PhotoInfo(title: "Wallpapers", url: res.urls, profile_image: owners[indexPath.row].profile_image)
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
                    let photoInfo = PhotoInfo(title: res.user?.name ?? "", url: res.urls, profile_image: profile)
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                    
                case .nature:
                    guard let res = viewModel.natureTopic.value?[indexPath.row] else {
                        return
                    }
                    
                    guard let owners = viewModel.natureTopic.value?[indexPath.row].owners else {
                        return
                    }
                    
                    let photoInfo = PhotoInfo(title: "Nature", url: res.preview_photos[indexPath.row].urls, profile_image: owners[indexPath.row].profile_image)
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                    
                case .wallpapers:
                    
                    guard let res = viewModel.wallpapersTopic.value?[indexPath.row] else {
                        return
                    }
                    
                    guard let owners = viewModel.natureTopic.value?[indexPath.row].owners else {
                        return
                    }
                    
                    let photoInfo = PhotoInfo(title: "Wallpapers", url: res.preview_photos[indexPath.row].urls, profile_image: owners[indexPath.row].profile_image)
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                case .collections:
                    break
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
//        guard let result = viewModel.searchRespone.value?.results else {
//            return
//        }
        
    //    print("indexPath row, \(indexPath.row)")
        
        let lastElement = collectionView.numberOfItems(inSection: indexPath.section) - 1
        if !viewModel.isLoading.value && indexPath.row == lastElement {
           // indicator.startAnimating()
            //currentPage =  currentPage + 1
            
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: collectionView.bounds.width, height: CGFloat(44))

            currentIndex = lastElement
            previousContentHeight = collectionView.contentSize.height
            previousContentOffset = collectionView.contentOffset.y
            viewModel.fetchNextPage()
            
        }
    }
}


// MARK: - Private
extension PhotoListView {
    
    func configureCell(collectionView: UICollectionView, respone: Response, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        cell?.titleLabel.text = respone.user?.name
        
        if let url = URL(string: respone.urls.thumb) {
            cell?.configureImage(with: url)
        }
        
        return cell
    }
   
    func configureTopicCell(collectionView: UICollectionView, respone: Preview_Photos, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        if section == .nature {
            
            cell?.titleLabel.text = "Nature"
            
            
        }else if section == .wallpapers {
            
            cell?.titleLabel.text = "Wallpapers"
        }
        
        if let url = URL(string: respone.urls.thumb) {
            cell?.configureImage(with: url)
        }
        
        return cell
    }

    func configureCollectionCell(collectionView: UICollectionView, respone: CollectionResponse, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        cell?.titleLabel.text = respone.user.name
        
        if let url = URL(string: respone.urls.thumb) {
            cell?.configureImage(with: url)
        }
        
        return cell
    }
}
