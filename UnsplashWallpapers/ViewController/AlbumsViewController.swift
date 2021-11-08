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
        
        //view.backgroundColor = .systemBackground
        
        view.addSubview(albumsView)
        
        let guide = self.view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            albumsView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            albumsView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            albumsView.topAnchor.constraint(equalTo: guide.topAnchor),
            albumsView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
         
        ])
       
        viewModel.featuredAlbumsRespone.bind { [weak self] (_) in
            
            DispatchQueue.main.async {
                self?.albumsView.configureDataSource()
            }
            
        }
        
        viewModel.allAlbumsRespone.bind { [weak self] (_) in
            
            DispatchQueue.main.async {
                self?.albumsView.configureDataSource()
            }
            
        }
        
        viewModel.sharedAlbumsRespone.bind { [weak self] (_) in
            
            DispatchQueue.main.async {
                self?.albumsView.configureDataSource()
            }
            
        }
        
        multipleAsyncOperations()
        
    }
    
    func multipleAsyncOperations() {
        
        if #available(iOS 15.0.0, *) {
            Task {
                try await downloadWithMultipleSource(images: 0)
                try await downloadWithMultipleSource(images: 1)
                try await downloadWithMultipleSource(images: 2)
            }
        } else {
            // Fallback on earlier versions
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
            
            group.notify(queue: .main) { [weak self] in

                self?.viewModel.featuredAlbumsRespone.bind { [weak self] (_) in

                    self?.albumsView.configureDataSource()
                }

                self?.viewModel.allAlbumsRespone.bind { [weak self] (_) in

                    self?.albumsView.configureDataSource()
                }
                
                self?.viewModel.sharedAlbumsRespone.bind { [weak self] (_) in
                    
                    self?.albumsView.configureDataSource()
                }
            }
        }
    }
    
    @available(iOS 15.0.0, *)
    func downloadAll(imageNumber: Int) async throws -> Bool {
        
        if imageNumber == 0 {
            self.viewModel.getFeaturedAlbums {  (success) in
                
            }
            
        } else if imageNumber == 1 {
            self.viewModel.getSharedAlbums {  (success) in
                
            }

        } else {
           
            self.viewModel.getAllAlbums { (success) in
                
            }

        }
       
        return true
 
    }
    
    @available(iOS 15.0.0, *)
    func downloadWithMultipleSource(images: Int...) async throws {
        var imagesMetadata: [Bool] = []
        try await withThrowingTaskGroup(of: Bool.self, body: { group in
            for image in images {
                group.addTask {
                    async let image = self.downloadAll(imageNumber: image)
                    
                    return try await image
                }
            }
            for try await image in group {
                imagesMetadata += [image]
                
            }
        })
    }
}
