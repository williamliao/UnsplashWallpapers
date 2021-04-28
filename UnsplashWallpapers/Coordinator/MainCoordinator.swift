//
//  MainCoordinator.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import UIKit

class MainCoordinator: Coordinator {
    
    // MARK: - Properties
    var rootViewController: UITabBarController
  
    
    // MARK: - Coordinator
    init(rootViewController: UITabBarController) {
        self.rootViewController = rootViewController
    }
    
    lazy var photoListViewModel: PhotoListViewModel! = {
        let viewdModel = PhotoListViewModel()
        return viewdModel
    }()
    
    lazy var detailViewModel: DetailViewModel! = {
        let viewdModel = DetailViewModel()
        return viewdModel
    }()
    
    lazy var searchViewModel: SearchViewModel! = {
        let viewdModel = SearchViewModel()
        return viewdModel
    }()
    
    lazy var favoriteViewModel: FavoriteViewModel! = {
        let viewdModel = FavoriteViewModel()
        return viewdModel
    }()

    override func start() {
        let main = createPhotoListView()
        let fav = createFavoriteView()
        let search = createSearchView()

        self.rootViewController.setViewControllers([main, search, fav], animated: false)
        
        if #available(iOS 13.0, *) {
            
            let tintColor = self.rootViewController.traitCollection.userInterfaceStyle == .light ? UIColor.black : UIColor.white
            
            self.rootViewController.tabBar.items?[0].image = UIImage(systemName: "square")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
            self.rootViewController.tabBar.items?[0].selectedImage = UIImage(systemName: "square.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
            
            self.rootViewController.tabBar.items?[1].image = UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
            self.rootViewController.tabBar.items?[1].selectedImage = UIImage(systemName: "magnifyingglass.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
     
            self.rootViewController.tabBar.items?[2].image = UIImage(systemName: "heart")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
            self.rootViewController.tabBar.items?[2].selectedImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func finish() {
        
    }
    
    func createPhotoListView() -> UINavigationController {
        let photo = PhotoListViewController()
        photo.title = "Photo"
        photo.viewModel = photoListViewModel
        photo.viewModel.coordinator = self
        let nav = UINavigationController(rootViewController: photo)
        return nav
    }
    
    func createDetailView() -> DetailViewController {
        let detail = DetailViewController()
        detail.viewModel = detailViewModel
        detail.title = "Detail"
        return detail
    }
    
    func createSearchView() -> UINavigationController {
        let search = SearchViewController()
        search.viewModel = searchViewModel
        search.viewModel.coordinator = self
        search.title = "Search"
        let nav = UINavigationController(rootViewController: search)
        return nav
    }
    
    func createFavoriteView() -> UINavigationController {
        let favorite = FavoriteViewController()
        favorite.viewModel = favoriteViewModel
        favorite.title = "Favorite"
        let nav = UINavigationController(rootViewController: favorite)
        return nav
    }
}

extension MainCoordinator {
    func goToDetailView(photoInfo: PhotoInfo) {
        let topDetailVC = createDetailView()
        topDetailVC.viewModel.photoInfo.value = photoInfo
       
        if let currentNavController = self.rootViewController.selectedViewController as? UINavigationController {
            currentNavController.pushViewController(topDetailVC, animated: true)
        }
    }
    
    func pushToCollectionListView(id: String, category: SearchResults.Category) {
        
        let photoListViewModel = PhotoListViewModel()
        photoListViewModel.fetchCollection(id: id)
        
        let photo = PhotoListViewController()
        photo.title = "Photo"
        photo.viewModel = photoListViewModel
        photo.viewModel.coordinator = self
        photo.isCollectionMode = true
        
        if let currentNavController = self.rootViewController.selectedViewController as? UINavigationController {
            currentNavController.pushViewController(photo, animated: true)
        }
    }
    
    func pushToUserProfileCollectionListView(userProfileInfo: UserProfileInfo) {
        
        let userProfileViewModel = UserProfileViewModel()
        userProfileViewModel.fetchUserPhotos(username: userProfileInfo.userName)
        userProfileViewModel.userProfileInfo = userProfileInfo
        
        let userProfile = UserProfileViewController()
        userProfile.viewModel = userProfileViewModel
        userProfile.viewModel.coordinator = self
        
        if let currentNavController = self.rootViewController.selectedViewController as? UINavigationController {
            currentNavController.pushViewController(userProfile, animated: true)
        }
    }
}
