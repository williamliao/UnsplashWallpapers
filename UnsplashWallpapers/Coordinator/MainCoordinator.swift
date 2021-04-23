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
    
    lazy var favoriteViewModel: FavoriteViewModel! = {
        let viewdModel = FavoriteViewModel()
        return viewdModel
    }()

    override func start() {
        let main = createPhotoListView()
        let fav = createFavoriteView()

        self.rootViewController.setViewControllers([main, fav], animated: false)
        
        if #available(iOS 13.0, *) {
            self.rootViewController.tabBar.items?[0].image = UIImage(systemName: "square")?.withRenderingMode(.alwaysOriginal)
            self.rootViewController.tabBar.items?[0].selectedImage = UIImage(systemName: "square.fill")?.withRenderingMode(.alwaysOriginal)
     
            self.rootViewController.tabBar.items?[1].image = UIImage(systemName: "heart")?.withRenderingMode(.alwaysOriginal)
            self.rootViewController.tabBar.items?[1].selectedImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysOriginal)
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
    
    func createFavoriteView() -> UINavigationController {
        let favorite = FavoriteViewController()
        favorite.viewModel = favoriteViewModel
        favorite.title = "Favorite"
        let nav = UINavigationController(rootViewController: favorite)
        return nav
    }
}

extension MainCoordinator {
    func goToDetailView(respone: Response) {
        let topDetailVC = createDetailView()
        topDetailVC.viewModel.respone.value = respone
       
        if let currentNavController = self.rootViewController.selectedViewController as? UINavigationController {
            currentNavController.pushViewController(topDetailVC, animated: true)
        }
    }
}
