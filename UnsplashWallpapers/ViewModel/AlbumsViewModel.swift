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
    
    var featureCursor: Cursor!
    var shareCursor: Cursor!
    var allCursor: Cursor!
    
    var unsplashFeaturePagedRequest: UnsplashSearchPagedRequest!
    var unsplashSharePagedRequest: UnsplashSearchPagedRequest!
    var unsplashAllPagedRequest: UnsplashSearchPagedRequest!
    
}

extension AlbumsViewModel {
    
    func getAllAlbums() {
        service.networkManager = NetworkManager(endPoint: .collections)
        
        isLoading.value = true
        
        if allCursor == nil {
            allCursor = Cursor(query: "cat", page: 1, perPage: 10, parameters: [:])
            unsplashAllPagedRequest = UnsplashSearchPagedRequest(with: allCursor)
        }
        
        service.search(keyword: unsplashAllPagedRequest.cursor.query ?? "", pageRequest: unsplashAllPagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    for index in 0...respone.results.count - 1 {
                        
                        var albumDetailItems:[AlbumDetailItem] = [AlbumDetailItem]()
                        
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
                            
                            if !albumDetailItems.contains(AlbumDetailItem(photoURL: detailItemUrl, thumbnailURL: detailItemUrl)) {
                                albumDetailItems.append(AlbumDetailItem(photoURL: detailItemUrl, thumbnailURL: detailItemUrl))
                            }
                            
                        }
                        
                        var isLandscape = false
                        if cover_photo.width > cover_photo.height {
                            isLandscape = true
                        }
                        
                        let albumItem = AlbumItem(albumTitle: title, albumURL: url, isLandscape: isLandscape, imageItems: albumDetailItems)
                        
                        self.allAlbumsRespone.value.append(albumItem)
                        
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
        
        isLoading.value = true
        
        if featureCursor == nil {
            featureCursor = Cursor(query: "nature", page: 1, perPage: 10, parameters: [:])
            unsplashFeaturePagedRequest = UnsplashSearchPagedRequest(with: featureCursor)
        }
        
        service.search(keyword: unsplashFeaturePagedRequest.cursor.query ?? "", pageRequest: unsplashFeaturePagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    for index in 0...respone.results.count - 1 {
                        
                        var albumDetailItems:[AlbumDetailItem] = [AlbumDetailItem]()
                        
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
                            
                            if !albumDetailItems.contains(AlbumDetailItem(photoURL: detailItemUrl, thumbnailURL: detailItemUrl)) {
                                albumDetailItems.append(AlbumDetailItem(photoURL: detailItemUrl, thumbnailURL: detailItemUrl))
                            }
                            
                        }
                        
                        var isLandscape = false
                        if cover_photo.width > cover_photo.height {
                            isLandscape = true
                        }
                        
                        let albumItem = AlbumItem(albumTitle: title, albumURL: url, isLandscape: isLandscape, imageItems: albumDetailItems)
                        
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
        service.networkManager = NetworkManager(endPoint: .collections)
        
        isLoading.value = true
        
        if shareCursor == nil {
            shareCursor = Cursor(query: "wallpapers", page: 1, perPage: 10, parameters: [:])
            unsplashSharePagedRequest = UnsplashSearchPagedRequest(with: shareCursor)
        }
        
        service.search(keyword: unsplashSharePagedRequest.cursor.query ?? "", pageRequest: unsplashSharePagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    for index in 0...respone.results.count - 1 {
                        
                        var albumDetailItems:[AlbumDetailItem] = [AlbumDetailItem]()
                        
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
                            
                            if !albumDetailItems.contains(AlbumDetailItem(photoURL: detailItemUrl, thumbnailURL: detailItemUrl)) {
                                albumDetailItems.append(AlbumDetailItem(photoURL: detailItemUrl, thumbnailURL: detailItemUrl))
                            }
                            
                        }
                        
                        var isLandscape = false
                        if cover_photo.width > cover_photo.height {
                            isLandscape = true
                        }
                        
                        let albumItem = AlbumItem(albumTitle: title, albumURL: url, isLandscape: isLandscape, imageItems: albumDetailItems)
                        
                        self.sharedAlbumsRespone.value.append(albumItem)
                        
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
    
    func reset() {
        
    }
}
