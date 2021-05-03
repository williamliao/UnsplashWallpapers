//
//  AlbumsViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import UIKit

class AlbumsViewController: UIViewController {
    
    var viewModel: AlbumsViewModel!
    var albumsView: AlbumsView!

    override func viewDidLoad() {
        super.viewDidLoad()

        albumsView = AlbumsView(viewModel: viewModel, coordinator: viewModel.coordinator)
        albumsView.translatesAutoresizingMaskIntoConstraints = false
        albumsView.configureCollectionView()
        albumsView.configureDataSource()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(albumsView)
        
        let guide = self.view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            albumsView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            albumsView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            albumsView.topAnchor.constraint(equalTo: guide.topAnchor),
            albumsView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
         
        ])
        
        let dispatchQueue = DispatchQueue(label: "com.prit.TestGCD.DispatchQueue")

        dispatchQueue.async {
            self.viewModel.getFeaturedAlbums()
        }
            
        dispatchQueue.async {
            self.viewModel.getSharedAlbums()
        }
            
        dispatchQueue.async {
            self.viewModel.getAllAlbums()
        }
        
        viewModel.featuredAlbumsRespone.bind { [weak self] (_) in

            self?.albumsView.configureDataSource()

        }

        viewModel.sharedAlbumsRespone.bind { [weak self] (_) in

            self?.albumsView.configureDataSource()

        }
        
        viewModel.allAlbumsRespone.bind { [weak self] (_) in
            
            self?.albumsView.configureDataSource()
            
        }
        
    }
}
