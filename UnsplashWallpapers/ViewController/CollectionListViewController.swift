//
//  CollectionListViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import UIKit

class CollectionListViewController: BaseViewController {
    
    var viewModel: CollectionListViewModel!
    var collectionView: CollectionListView!

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView = CollectionListView(viewModel: viewModel, coordinator: viewModel.coordinator)
        collectionView.configureCollectionView()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])
        
        viewModel.collectionListResponse.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.collectionView.applyInitialSnapshots()
            } else {
                //self?.searchView.reloadData()
            }
        }
        
        viewModel.error.bind { (error) in
            guard let error = error else {
                return
            }
            
            print("CollectionListViewController error", error)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.cancelWhenViewDidDisappear()
    }

}
