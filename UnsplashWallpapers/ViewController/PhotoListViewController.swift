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
        photoListView.configureCollectionView()
        photoListView.createSegmentView()
        photoListView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(photoListView)
        
        NSLayoutConstraint.activate([
            photoListView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            photoListView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            photoListView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            photoListView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])

        if isCollectionMode {
            photoListView.section = .collections
        }
        
        viewModel.respone.bind { [weak self] (_) in
            
            self?.photoListView.hideCollectionView(hide: false)
            
            if #available(iOS 13.0, *) {
                self?.photoListView.applyInitialSnapshots()
            } else {
                self?.photoListView.reloadData()
            }
        }
        
        viewModel.searchRespone.bind { [weak self] (_) in
            self?.photoListView.hideCollectionView(hide: false)
            if #available(iOS 13.0, *) {
                self?.photoListView.applyInitialSnapshots()
            } else {
                self?.photoListView.reloadData()
            }
        }
        
        viewModel.wallpapersTopic.bind { [weak self] (_) in
            self?.photoListView.hideCollectionView(hide: false)
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
            
            let errorCode = (error as NSError).code

            print("errorCode \(errorCode)")
            
            if errorCode == 6 {
                print("switchToOfflineView")
                self.photoListView.switchToOfflineView()
            }
            
            
            
        }

        viewModel.fetchData()
    }
    
}
