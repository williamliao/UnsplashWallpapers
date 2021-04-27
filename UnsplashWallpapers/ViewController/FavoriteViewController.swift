//
//  FavoriteViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/22.
//

import UIKit

class FavoriteViewController: UIViewController {
    
    var viewModel: FavoriteViewModel!
   
    var favoriteView: FavoriteView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteView = FavoriteView(viewModel: viewModel)
        favoriteView.configureTableView(Add: self.view)
        favoriteView.makeDateSourceForTableView()
        
        viewModel.photoInfo.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.favoriteView.applyInitialSnapshots()
            } else {
                self?.favoriteView.tableView.reloadData()
            }
        }
        
        viewModel.error.bind { (error) in
            guard let error = error else {
                return
            }
            
            print("error", error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadFavorite()
    }
}
