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
       
        multipleAsyncOperations()
    }
    
    func multipleAsyncOperations() {
        let group = DispatchGroup()
        
        let apiGroup = [0, 1, 2]
        
        
        for url in apiGroup {
            
            group.enter()
            
            if url == 0 {
                self.viewModel.getFeaturedAlbums { (success) in
                    group.leave()
                }
                
            } else if url == 1 {
                self.viewModel.getSharedAlbums { (success) in
                    group.leave()
                }

            } else {
                self.viewModel.getAllAlbums { (success) in
                    group.leave()
                }

            }
            
        }
        
        group.notify(queue: .main) {

            self.viewModel.featuredAlbumsRespone.bind { [weak self] (_) in

                self?.albumsView.configureDataSource()
            }

            self.viewModel.allAlbumsRespone.bind { [weak self] (_) in

                self?.albumsView.configureDataSource()
            }
            
            self.viewModel.sharedAlbumsRespone.bind { [weak self] (_) in
                
                self?.albumsView.configureDataSource()
            }
        }
    }
}
