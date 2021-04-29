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
    
    var viewModel: UserProfileViewModel
    
    @available(iOS 13.0, *)
    lazy var dataSource  = makeUserListPhotosDataSource()
    
    var coordinator: MainCoordinator?
    
    var section: UserProfileCurrentSource = .photos
    
    var currentIndex = 0;
    
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
        let userProfileHeaderView = UserProfileHeaderView()
        userProfileHeaderView.translatesAutoresizingMaskIntoConstraints = false
        
        userProfileHeaderView.titleLabel.text = viewModel.userProfileInfo.name
        
        if let url = URL(string: viewModel.userProfileInfo.profile_image.small) {
            userProfileHeaderView.configureImage(with: url)
        } else {
            let tintColor = self.traitCollection.userInterfaceStyle == .light ? UIColor.black : UIColor.white
            userProfileHeaderView.avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
        }
        
        self.addSubview(userProfileHeaderView)
        
        NSLayoutConstraint.activate([
            userProfileHeaderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            userProfileHeaderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            userProfileHeaderView.topAnchor.constraint(equalTo: self.topAnchor),
            userProfileHeaderView.heightAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    func configureCollectionView() {
       
        self.backgroundColor = .systemBackground
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.estimatedItemSize = .zero

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
            collectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 100),
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
                print("Photos")
                break
            case 1:
                print("Likes")
                break
            case 2:
                print("Collections")
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
        
        if let url = URL(string: respone.urls.small) {
            cell?.configureImage(with: url)
        }
        
        return cell
    }
}

// MARK:- ReloadData
extension UserProfileView {
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        
        switch section {
            case .photos:
                var snapshot = NSDiffableDataSourceSnapshot<Section, CollectionResponse>()
                if (!firstLoad) {
                    dataSource = makeUserListPhotosDataSource()
                } else {
                    dataSource = getUserListPhotosDatasource()
                }
                
                //Append available sections
                Section.allCases.forEach { snapshot.appendSections([$0]) }
                
                //Append annotations to their corresponding sections
                
                viewModel.userPhotosResponse.value?.forEach { (respone) in
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
                
            case .likes:
                break
                
            case .collections:
                break
        }
    }
}

// MARK: - UICollectionViewDelegate
extension UserProfileView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if #available(iOS 13.0, *) {
            
            switch section {
                case .photos:
                    guard let res = dataSource.itemIdentifier(for: indexPath)  else {
                        return
                    }
                    
                    let photoInfo = PhotoInfo(title: res.user.name, url: res.urls, profile_image: res.user.profile_image)
                    coordinator?.goToDetailView(photoInfo: photoInfo)
                    
                case .likes:
                    break
                    
                case .collections:
                    break
            }
            
        } else {
            
            switch section {
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

        let lastElement = collectionView.numberOfItems(inSection: indexPath.section) - 1
        if !viewModel.isLoading.value && indexPath.row == lastElement {
    
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: collectionView.bounds.width, height: CGFloat(44))

            currentIndex = lastElement
            viewModel.fetchNextPage()
            
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
