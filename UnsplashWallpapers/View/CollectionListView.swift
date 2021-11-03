//
//  CollectionListView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import UIKit

class CollectionListView: UIView {
    // MARK: - component
    var collectionView: UICollectionView!
    
    var viewModel: CollectionListViewModel
    
    var coordinator: MainCoordinator?
    
    @available(iOS 13.0, *)
    lazy var dataSource  = makeUserListPhotosDataSource()
    
    // MARK:- property
    var firstLoad = true
    var currentIndex = 0
    var endRect = CGRect.zero
    var imageHeightDictionary: [IndexPath: String]?
    
    init(viewModel: CollectionListViewModel, coordinator: MainCoordinator?) {
        self.viewModel = viewModel
        self.coordinator = viewModel.coordinator
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CollectionListView {
    func configureCollectionView() {
       
        //self.backgroundColor = .systemBackground
        
        let flowLayout = UICollectionViewFlowLayout()
        //flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        //flowLayout.estimatedItemSize = .zero

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        makeDateSourceForCollectionView()
        
        collectionView.register(PhotoListCollectionViewCell.self
                                , forCellWithReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier)
        
        
        self.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
    }
    
    func makeDateSourceForCollectionView() {
        if #available(iOS 13.0, *) {
           
            if (!firstLoad) {
                dataSource = makeUserListPhotosDataSource()
                collectionView.dataSource = dataSource
                return
            }
            
            collectionView.dataSource = dataSource
            firstLoad = false
            
        } else {
            //collectionView.dataSource = self
        }
    }
}

// MARK:- UserListPhotos
extension CollectionListView {
    
    @available(iOS 13.0, *)
    private func getUserListPhotosDatasource() -> UICollectionViewDiffableDataSource<Section, CollectionResponse> {
        return dataSource
    }
    
    func makeUserListPhotosDataSource() -> UICollectionViewDiffableDataSource<Section, CollectionResponse> {
        
        return UICollectionViewDiffableDataSource<Section, CollectionResponse>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            let cell = self.configureCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    func configureCell(collectionView: UICollectionView, respone: CollectionResponse, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        cell?.titleLabel.text = respone.user.name
        
        if let url = URL(string: respone.urls.small) {
            cell?.configureImage(with: url)
        }
        
        return cell
    }
}

// MARK:- ReloadData
extension CollectionListView {
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, CollectionResponse>()
        dataSource = getUserListPhotosDatasource()
        
        //Append available sections
        Section.allCases.forEach { snapshot.appendSections([$0]) }
        
        //Append annotations to their corresponding sections
        
        guard let collections = viewModel.collectionListResponse.value else {
            return
        }
        
        collections.forEach { (collection) in
            snapshot.appendItems([collection], toSection: .main)
        }
        
       // UIView.performWithoutAnimation {
            //Force the update on the main thread to silence a warning about collectionView not being in the hierarchy!
            DispatchQueue.main.async {
                self.dataSource.apply(snapshot, animatingDifferences: false)
                self.collectionView.layoutIfNeeded()
                self.collectionView.scrollRectToVisible(self.endRect, animated: false)
            }
       // }
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if #available(iOS 13.0, *) {
            
            guard let res = dataSource.itemIdentifier(for: indexPath)  else {
                return
            }
            
            let photoInfo = PhotoInfo(id: res.id, title: res.user.name, url: res.urls, profile_image: res.user.profile_image, width: CGFloat(res.width), height: CGFloat(res.height))
            coordinator?.goToDetailView(photoInfo: photoInfo)
            
            
        } else {
            
            guard let res = viewModel.collectionListResponse.value?[indexPath.row] else {
                return
            }
            
            let photoInfo = PhotoInfo(id: res.id, title: res.user.name, url: res.urls, profile_image: res.user.profile_image, width: CGFloat(res.width), height: CGFloat(res.height))
            coordinator?.goToDetailView(photoInfo: photoInfo)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let lastElement = collectionView.numberOfItems(inSection: indexPath.section) - 3
        if !viewModel.isLoading.value && indexPath.row == lastElement {
    
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: collectionView.bounds.width, height: CGFloat(44))
            
            currentIndex = lastElement
            viewModel.fetchNextPage()
            
            if !viewModel.isLoading.value && indexPath.row == lastElement {
                let theAttributes = collectionView.layoutAttributesForItem(at: indexPath)
                endRect = theAttributes?.frame ?? CGRect.zero
            }
            
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

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
