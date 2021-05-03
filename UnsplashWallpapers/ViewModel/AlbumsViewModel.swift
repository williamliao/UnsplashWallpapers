//
//  AlbumsViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import Foundation

class AlbumsViewModel {
    
    var coordinator: MainCoordinator?
    
    var allAlbumsRespone: Observable<[AlbumItem]> = Observable([])
    var featuredAlbumsRespone: Observable<[AlbumItem]> = Observable([])
    var sharedAlbumsRespone: Observable<[AlbumItem]> = Observable([])
    
    var isLoading: Observable<Bool> = Observable(false)
    var error: Observable<Error?> = Observable(nil)
    
    let service: UnsplashService = UnsplashService()
    
    var albumsCursor: Cursor!
    var unsplashAlbumsRequest: UnsplashAlbumsRequest!
    
    
    var collectionsCursor: Cursor!
    
    var unsplashSearchPagedRequest: UnsplashSearchPagedRequest!
}

extension AlbumsViewModel {
    
    func getAllAlbums() {
        service.networkManager = NetworkManager(endPoint: .random)
        
        if albumsCursor == nil {
            albumsCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashAlbumsRequest = UnsplashAlbumsRequest(with: albumsCursor)
        }
        
        isLoading.value = true
        
        service.getAllAlbum(query: "cat", pageRequest: unsplashAlbumsRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respones):
                    
                    for respone in respones {
                        
                        guard let url = URL(string: respone.urls.small), let detailUrl = URL(string: respone.urls.regular), let title = respone.user?.name   else {
                            return
                        }
                        
                        
                    }
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print(code)
                        default:
                            self.error.value = error
                    }
            }
        }
    }
    
    func getFeaturedAlbums() {
        service.networkManager = NetworkManager(endPoint: .collections)
        
        if albumsCursor == nil {
            albumsCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashAlbumsRequest = UnsplashAlbumsRequest(with: albumsCursor)
        }
        
        isLoading.value = true
        
        if collectionsCursor == nil {
            collectionsCursor = Cursor(query: "nature", page: 1, perPage: 10, parameters: [:])
            unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: collectionsCursor)
        }
        
        service.search(keyword: unsplashSearchPagedRequest.cursor.query ?? "", pageRequest: unsplashSearchPagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    var albumDetailItems:[AlbumDetailItem] = [AlbumDetailItem]()
                   
                    for index in 0...respone.results.count - 1 {
                        
                        guard let cover_photo = respone.results[index].cover_photo , let url = URL(string: cover_photo.urls.small), let title = respone.results[index].user?.name  else {
                            return
                        }
                        
                        guard let preview_photos = respone.results[index].preview_photos  else {
                            return
                        }
                        
                        for index in 0...preview_photos.count - 1 {
                            
                            guard let detailItemUrl = URL(string: preview_photos[index].urls.small)  else {
                                return
                            }
                            albumDetailItems.append(AlbumDetailItem(photoURL: detailItemUrl, thumbnailURL: detailItemUrl))
                            
                        }
                        
                        let albumItem = AlbumItem(albumTitle: title, albumURL: url, imageItems: albumDetailItems)
                        
                        self.featuredAlbumsRespone.value.append(albumItem)
                    }
                    
                    
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print(code)
                        default:
                            self.error.value = error
                    }
            }
        }
    }
    
    func getSharedAlbums() {
        service.networkManager = NetworkManager(endPoint: .random)
        
        if albumsCursor == nil {
            albumsCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashAlbumsRequest = UnsplashAlbumsRequest(with: albumsCursor)
        }
        
        isLoading.value = true
        
        service.getAllAlbum(query: "people", pageRequest: unsplashAlbumsRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respones):
                    
                    for respone in respones {
                        
                        guard let url = URL(string: respone.urls.small), let detailUrl = URL(string: respone.urls.regular), let title = respone.user?.name   else {
                            return
                        }
                        
                        
                    }
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print(code)
                        default:
                            self.error.value = error
                    }
            }
        }
    }
}
