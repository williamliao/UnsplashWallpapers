//
//  PhotoListViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import UIKit

class PhotoListViewController: UIViewController {
    
    var viewModel: PhotoListViewModel!
    
    var photoListView: PhotoListView!
    
    var isCollectionMode: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        photoListView = PhotoListView(viewModel: viewModel, coordinator: viewModel.coordinator)
        photoListView.configureCollectionView(Add: self.view)
        photoListView.createSegmentView(view: self.view)

        if isCollectionMode {
            photoListView.section = .collections
        }
        
        viewModel.respone.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.photoListView.applyInitialSnapshots()
            } else {
                self?.photoListView.reloadData()
            }
        }
        
        viewModel.searchRespone.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.photoListView.applyInitialSnapshots()
            } else {
                self?.photoListView.reloadData()
            }
        }
        
        viewModel.wallpapersTopic.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.photoListView.applyInitialSnapshots()
            } else {
                self?.photoListView.reloadData()
            }
        }
        
//        viewModel.collectionResponse.bind { [weak self] (_) in
//            if #available(iOS 13.0, *) {
//                self?.photoListView.applyInitialSnapshots()
//            } else {
//                self?.photoListView.reloadData()
//            }
//        }
        
        viewModel.error.bind { (error) in
            guard let error = error else {
                return
            }
            
            print("error", error)
        }

        viewModel.fetchData()
    }
    
}
