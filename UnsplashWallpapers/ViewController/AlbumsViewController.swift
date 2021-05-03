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

        let semaphore = DispatchSemaphore(value: 2)
            
        dispatchQueue.async {
            let result = semaphore.wait(timeout: DispatchTime.distantFuture)
            
            Thread.sleep(forTimeInterval: 2)
            self.viewModel.getFeaturedAlbums()
            semaphore.signal()
        }
            
        dispatchQueue.async {
            semaphore.wait(timeout: DispatchTime.distantFuture)
            Thread.sleep(forTimeInterval: 2)
            self.viewModel.getSharedAlbums()
            semaphore.signal()
        }
            
        dispatchQueue.async {
            self.viewModel.getAllAlbums()
            semaphore.signal()
        }
        
//        viewModel.featuredAlbumsRespone.bind { [weak self] (_) in
//
//            self?.albumsView.configureDataSource()
//
//        }
//
//        viewModel.sharedAlbumsRespone.bind { [weak self] (_) in
//
//            self?.albumsView.configureDataSource()
//
//        }
        
        viewModel.allAlbumsRespone.bind { [weak self] (_) in
            
            self?.albumsView.configureDataSource()
            
        }
        
    }
}
