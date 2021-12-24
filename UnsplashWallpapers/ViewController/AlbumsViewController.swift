//
//  AlbumsViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import UIKit

enum AlbumType {
    case featured
    case shared
    case all
}

struct Descriptor {
    let id: UUID
    let type: AlbumType
}

enum TaskResult {
    case featured(UUID)
    case shared(UUID)
    case all(UUID)
}

class AlbumsViewController: BaseViewController {
    
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
        
        viewModel.error.bind { error in
            
            guard let error = error else {
                return
            }
            print("showError \(error)")
        }
        
        multipleAsyncOperations()
        
    }
    
    func multipleAsyncOperations() {
        
        if #available(iOS 13.0.0, *) {
            Task {
                //await downloadWithMultipleSource()
                
                let operations = [
                     Descriptor(id: UUID(), type: .featured),
                     Descriptor(id: UUID(), type: .shared),
                     Descriptor(id: UUID(), type: .all)
                ]
                
                let taskResults = try await fetchAlbums(descriptors: operations)
                
                for task in taskResults {
                    switch task {
                        case .featured(let id):
                            print("featured task id \(id)")
                        case .shared(let id):
                            print("shared task id \(id)")
                        case .all(let id):
                            print("all task id \(id)")
                    }
                }
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
    
    @available(iOS 13.0.0, *)
    func downloadAll(imageNumber: Int) {
        
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
       
    }
    
    @available(iOS 13.0.0, *)
    func downloadWithMultipleSource() async {
        print("AlbumView Before task group")
        
        await withThrowingTaskGroup(of: Void.self, body: { group -> Void in
            for i in 0...2 {
                group.addTask {
                    print("AlbumView Task completed")
                    try Task.checkCancellation()
                    await self.downloadAll(imageNumber: i)
                }
            }
            
            print("AlbumView For loop completed")
        })
        print("AlbumView After task group")
    }
    
    @available(iOS 13.0.0, *)
    func fetchAlbums(descriptors: [Descriptor]) async throws -> [TaskResult] {
        
        var results = [TaskResult]()
        
        do {
            try await withThrowingTaskGroup(of: TaskResult.self) { [unowned self] taskGroup in

                for descriptor in descriptors {
                    
                    if UnsplashAPI.secretKey.isEmpty && UnsplashAPI.accessKey.isEmpty {
                        throw ServerError.unAuthorized
                    }
                    
                    try Task.checkCancellation()
                    taskGroup.addTask {
                        switch descriptor.type {
                            case .featured:
                                await self.viewModel.getFeaturedAlbums {  (success) in
                                    
                                }
                                return TaskResult.featured(descriptor.id)
                            case .shared:
                                await self.viewModel.getSharedAlbums {  (success) in

                                }
                                return TaskResult.shared(descriptor.id)
                            case .all:
                                await self.viewModel.getAllAlbums {  (success) in

                                }
                                return TaskResult.all(descriptor.id)
                        }
                    }
                }
                
                for try await result in taskGroup {
                    results.append(result)
                }
                
            }
            
            print("👍🏻 Task group completed with result: \(results)")
            
        } catch  {
            print("👎🏻 Task group throws error: \(error)")
        }
        
        return results
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.cancelWhenViewDidDisappear()
    }
}
