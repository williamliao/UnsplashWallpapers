//
//  UserProfileView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import UIKit

enum UserProfileCurrentSource: Int, CaseIterable {
    case photos
    case likes
    case collections
}

class UserProfileView: UIView {
    // MARK: - component
    var collectionView: UICollectionView!
    
    let userProfileHeaderView = UserProfileHeaderView()
    
    var viewModel: UserProfileViewModel
    
    @available(iOS 13.0, *)
    lazy var dataSource  = makeUserListPhotosDataSource()
    
    @available(iOS 13.0, *)
    lazy var likeDataSource  = makeUserLikesPhotosDataSource()
    
    @available(iOS 13.0, *)
    lazy var collectionsDataSource  = makeUserCollectionsDataSource()
    
    var coordinator: MainCoordinator?
    
    //var section: UserProfileCurrentSource = .photos
    
    var currentIndex = 0;
    var endRect = CGRect.zero
    
    init(viewModel: UserProfileViewModel, coordinator: MainCoordinator?) {
        self.viewModel = viewModel
        self.coordinator = viewModel.coordinator
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- property
    var firstLoad = true
    
    let items = ["Photos", "Likes", "Collections"]
    lazy var segmentedControl = UISegmentedControl(items: items)
}

// MARK:- Create View
extension UserProfileView {
    
    func createUserProfileHeaderView() {
        
        userProfileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        userProfileHeaderView.titleLabel.text = viewModel.userProfileInfo.name
        
        if let url = URL(string: viewModel.userProfileInfo.profile_image.small) {
            userProfileHeaderView.configureImage(with: url)
        } else {
            let tintColor = self.traitCollection.userInterfaceStyle == .light ? UIColor.black : UIColor.white
            userProfileHeaderView.avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
        }
        
        self.addSubview(userProfileHeaderView)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            userProfileHeaderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            userProfileHeaderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            userProfileHeaderView.topAnchor.constraint(equalTo: self.topAnchor),
            userProfileHeaderView.heightAnchor.constraint(equalToConstant: 100),
        ])
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            segmentedControl.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            segmentedControl.topAnchor.constraint(equalTo: userProfileHeaderView.bottomAnchor),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    func configureCollectionView() {
       
        self.backgroundColor = .systemBackground
        
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
    
    func createSegmentView() {
        segmentedControl.frame = CGRect.zero
        segmentedControl.addTarget(self, action: #selector(segmentAction(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
        self.addSubview(segmentedControl)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func segmentAction(_ segmentedControl: UISegmentedControl) {
        switch (segmentedControl.selectedSegmentIndex) {
            case 0:
                viewModel.section = .photos
                
                guard let count = viewModel.userPhotosResponse.value?.count  else {
                    return
                }
                
                if count == 0 {
                    viewModel.fetchUserPhotos(username: viewModel.userProfileInfo.userName)
                } else {
                    self.applyInitialSnapshots()
                }
                break
            case 1:
                viewModel.section = .likes
                
                guard let count = viewModel.userLikesResponse.value?.count  else {
                    return
                }
                
                if count == 0 {
                    viewModel.fetchUserLikePhotos(username: viewModel.userProfileInfo.userName)
                } else {
                    self.applyInitialSnapshots()
                }
                break
            case 2:
                viewModel.section = .collections
                guard let count = viewModel.userCollectionsResponse.value?.count  else {
                    return
                }
                
                if count == 0 {
                    viewModel.fetchUserCollectons(username: viewModel.userProfileInfo.userName)
                } else {
                    self.applyInitialSnapshots()
                }
                break
            default:
                break
        }
    }
}

// MARK:- UserListPhotos
extension UserProfileView {
    
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
        
        cell?.titleLabel.text = viewModel.userProfileInfo.name
        
        if let url = URL(string: respone.urls.small) {
            cell?.configureImage(with: url)
        }
        
        return cell
    }
}

// MARK:- UserLikesPhotos
extension UserProfileView {
    
    @available(iOS 13.0, *)
    private func getUserLikesPhotosDatasource() -> UICollectionViewDiffableDataSource<Section, CollectionResponse> {
        return likeDataSource
    }
    
    func makeUserLikesPhotosDataSource() -> UICollectionViewDiffableDataSource<Section, CollectionResponse> {
        
        return UICollectionViewDiffableDataSource<Section, CollectionResponse>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            let cell = self.configureCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
}

// MARK:- UserCollections
extension UserProfileView {
    
    @available(iOS 13.0, *)
    private func getUserCollectionsDatasource() -> UICollectionViewDiffableDataSource<Section, UserCollectionRespone> {
        return collectionsDataSource
    }
    
    func makeUserCollectionsDataSource() -> UICollectionViewDiffableDataSource<Section, UserCollectionRespone> {
        
        return UICollectionViewDiffableDataSource<Section, UserCollectionRespone>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            let cell = self.configureCollectionsCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    func configureCollectionsCell(collectionView: UICollectionView, respone: UserCollectionRespone, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        cell?.titleLabel.text = viewModel.userProfileInfo.name
        
        if let url = URL(string: respone.cover_photo.url.small) {
            cell?.configureImage(with: url)
        }
        
        return cell
    }
}

// MARK:- ReloadData
extension UserProfileView {
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, CollectionResponse>()
        
        //Append available sections
        Section.allCases.forEach { snapshot.appendSections([$0]) }
        
        switch viewModel.section {
            case .photos:
                
                dataSource = getUserListPhotosDatasource()
                
                //Append annotations to their corresponding sections
                viewModel.userPhotosResponse.value?.forEach { (respone) in
                    snapshot.appendItems([respone], toSection: .main)
                }
                
                reloadDataSource(dataSource: dataSource, snapshot: snapshot)
                
            case .likes:
                
                likeDataSource = getUserLikesPhotosDatasource()
                
                //Append annotations to their corresponding sections
                viewModel.userLikesResponse.value?.forEach { (respone) in
                    snapshot.appendItems([respone], toSection: .main)
                }
                
                reloadDataSource(dataSource: likeDataSource, snapshot: snapshot)
                
            case .collections:
                
                var snapshot = NSDiffableDataSourceSnapshot<Section, UserCollectionRespone>()
                
                //Append available sections
                Section.allCases.forEach { snapshot.appendSections([$0]) }
                
                collectionsDataSource = getUserCollectionsDatasource()
                
                //Append annotations to their corresponding sections
                viewModel.userCollectionsResponse.value?.forEach { (respone) in
                    snapshot.appendItems([respone], toSection: .main)
                }
                
                DispatchQueue.main.async {
                    self.collectionsDataSource.apply(snapshot, animatingDifferences: false)
                    
                    if (self.currentIndex > 0) {
                        UIView.animate(withDuration: 0.25) {
                            self.collectionView.scrollToItem(at: IndexPath(row: self.currentIndex, section: Section.main.rawValue), at: .bottom, animated: false)
                        }
                    }
                    
                }
                
                break
        }
    }
    
    func reloadDataSource(dataSource: UICollectionViewDiffableDataSource<Section, CollectionResponse>, snapshot: NSDiffableDataSourceSnapshot<Section, CollectionResponse>) {
        
        
        //UIView.performWithoutAnimation {
            //Force the update on the main thread to silence a warning about collectionView not being in the hierarchy!
            DispatchQueue.main.async {
                dataSource.apply(snapshot, animatingDifferences: false)
                self.collectionView.layoutIfNeeded()
                self.collectionView.scrollRectToVisible(self.endRect, animated: false)
            }
       // }
    }
}

// MARK: - UICollectionViewDelegate
extension UserProfileView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if #available(iOS 13.0, *) {
            
            switch viewModel.section {
                case .photos:
                    guard let res = dataSource.itemIdentifier(for: indexPath)   else {
                        return
                    }
                    
                    let photoInfo = PhotoInfo(id: res.id, title: res.user.name, url: res.urls, profile_image: res.user.profile_image, width: CGFloat(res.width), height: CGFloat(res.height))
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                    
                case .likes:
                    
                    guard let res = likeDataSource.itemIdentifier(for: indexPath)  else {
                        return
                    }
                    
                    let photoInfo = PhotoInfo(id: res.id, title: res.user.name, url: res.urls, profile_image: res.user.profile_image, width: CGFloat(res.width), height: CGFloat(res.height))
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                    break
                    
                case .collections:
                    
                    guard let res = collectionsDataSource.itemIdentifier(for: indexPath)  else {
                        return
                    }
                    coordinator?.pushToCollectionListView(id: res.id)
                    break
            }
            
        } else {
            
            switch viewModel.section {
                case .photos:
                    break
                    
                case .likes:
                    break
                    
                case .collections:
                    break
            }
            
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


// MARK: - UICollectionViewDataSource
extension UserProfileView: UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let count = viewModel.userPhotosResponse.value?.count else {
          return 0
        }
        
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let res = viewModel.userPhotosResponse.value else {
          return UICollectionViewCell()
        }
        
        guard let cell = self.configureCell(collectionView: collectionView, respone: res[indexPath.row], indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension UserProfileView: UICollectionViewDelegateFlowLayout {
    
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
