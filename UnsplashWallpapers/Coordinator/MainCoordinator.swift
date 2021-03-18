//
//  MainCoordinator.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import UIKit

class MainCoordinator: Coordinator {
    
    // MARK: - Properties
    var rootViewController: UINavigationController
  
    
    // MARK: - Coordinator
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }
    
    lazy var photoListViewModel: PhotoListViewModel! = {
        let viewdModel = PhotoListViewModel()
        return viewdModel
    }()
    
    override func start() {
        let main = createPhotoListView()
        self.rootViewController.pushViewController(main, animated: true)
    }
    
    override func finish() {
        
    }
    
    func createPhotoListView() -> UIViewController {
        let photo = PhotoListViewController()
        photo.title = "Photo"
        photo.viewModel = photoListViewModel
        photo.viewModel.coordinator = self
        return photo
    }
    
    func goToDetailView(respone: Response) {
        //let topDetailVC = createDetailView()
        
        //topDetailVC.viewModel.respone.value = respone
        
        //rootViewController.pushViewController(topDetailVC, animated: true)
    }
}
