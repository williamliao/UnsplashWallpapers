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
    
    func getAllAlbums(completionHandler: @escaping (Bool) -> Void) {
        service.networkManager = NetworkManager(endPoint: .collections)
        
        if allCursor == nil {
            allCursor = Cursor(query: "cat", page: 1, perPage: 10, parameters: [:])
            unsplashAllPagedRequest = UnsplashSearchPagedRequest(with: allCursor)
        }
        
        isLoading.value = true
        
        service.search(keyword: unsplashAllPagedRequest.cursor.query ?? "", pageRequest: unsplashAllPagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    for index in 0...respone.results.count - 1 {
                        
                        var albumDetailItems:[AlbumDetailItem] = [AlbumDetailItem]()
                        
                        guard let cover_photo = respone.results[index].cover_photo , let url = URL(string: cover_photo.urls.small), let title = respone.results[index].user?.name, let profile = respone.results[index].user?.profile_image, let owner = respone.results[index].user?.profile_image.small  else {
                            return
                        }
                        
                        
                        guard let preview_photos = respone.results[index].preview_photos  else {
                            return
                        }
                        
                        for index in 0...preview_photos.count - 1 {
                            
                            guard let detailItemUrl = URL(string: preview_photos[index].urls.small)  else {
                                return
                            }
                            
                            let albumDetailItem = AlbumDetailItem(identifier: preview_photos[index].id, title: title, photoURL: detailItemUrl, thumbnailURL: detailItemUrl, profile_image: profile, urls: preview_photos[index].urls)
                            
                            if !albumDetailItems.contains(albumDetailItem) {
                                albumDetailItems.append(albumDetailItem)
                            }
                            
                        }
                        
                        var isLandscape = false
                        if cover_photo.width > cover_photo.height {
                            isLandscape = true
                        }
                        
                        guard let ownerURL = URL(string: owner) else {
                            return
                        }
                        
                        let albumItem = AlbumItem(albumTitle: "Cats", albumURL: url, ownerTitle: title, ownerURL: ownerURL, isLandscape: isLandscape, imageItems: albumDetailItems)
                        
                        self.allAlbumsRespone.value.append(albumItem)
                        
                    }
                    
                    completionHandler(true)
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print(code)
                        default:
                            self.error.value = error
                    }
                    
                    completionHandler(false)
            }
        }
    }
    
    func getFeaturedAlbums(completionHandler: @escaping (Bool) -> Void) {
        service.networkManager = NetworkManager(endPoint: .collections)
        
        if featureCursor == nil {
            featureCursor = Cursor(query: "nature", page: 1, perPage: 10, parameters: [:])
            unsplashFeaturePagedRequest = UnsplashSearchPagedRequest(with: featureCursor)
        }
        
        isLoading.value = true
        
        service.search(keyword: unsplashFeaturePagedRequest.cursor.query ?? "", pageRequest: unsplashFeaturePagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    for index in 0...respone.results.count - 1 {
                        
                        var albumDetailItems:[AlbumDetailItem] = [AlbumDetailItem]()
                        
                        guard let cover_photo = respone.results[index].cover_photo , let url = URL(string: cover_photo.urls.small), let title = respone.results[index].user?.name, let profile = respone.results[index].user?.profile_image, let owner = respone.results[index].user?.profile_image.small  else {
                            return
                        }
                        
                        
                        guard let preview_photos = respone.results[index].preview_photos  else {
                            return
                        }
                        
                        for index in 0...preview_photos.count - 1 {
                            
                            guard let detailItemUrl = URL(string: preview_photos[index].urls.small)  else {
                                return
                            }
                            
                            let albumDetailItem = AlbumDetailItem(identifier: preview_photos[index].id , title: title, photoURL: detailItemUrl, thumbnailURL: detailItemUrl, profile_image: profile, urls: preview_photos[index].urls)
                            
                            if !albumDetailItems.contains(albumDetailItem) {
                                albumDetailItems.append(albumDetailItem)
                            }
                            
                        }
                        
                        var isLandscape = false
                        if cover_photo.width > cover_photo.height {
                            isLandscape = true
                        }
                        
                        guard let ownerURL = URL(string: owner) else {
                            return
                        }
                        
                        let albumItem = AlbumItem(albumTitle: "Nature", albumURL: url, ownerTitle: title, ownerURL: ownerURL, isLandscape: isLandscape, imageItems: albumDetailItems)
                        
                        self.featuredAlbumsRespone.value.append(albumItem)
                    }
                    
                    completionHandler(true)
                    
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print(code)
                        default:
                            self.error.value = error
                    }
                    completionHandler(false)
            }
        }
    }
    
    func getSharedAlbums(completionHandler: @escaping (Bool) -> Void) {
        service.networkManager = NetworkManager(endPoint: .collections)
        
        if shareCursor == nil {
            shareCursor = Cursor(query: "wallpapers", page: 1, perPage: 10, parameters: [:])
            unsplashSharePagedRequest = UnsplashSearchPagedRequest(with: shareCursor)
        }
        
        isLoading.value = true
        
        service.search(keyword: unsplashSharePagedRequest.cursor.query ?? "", pageRequest: unsplashSharePagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    for index in 0...respone.results.count - 1 {
                        
                        var albumDetailItems:[AlbumDetailItem] = [AlbumDetailItem]()
                        
                        guard let cover_photo = respone.results[index].cover_photo , let url = URL(string: cover_photo.urls.small), let title = respone.results[index].user?.name, let profile = respone.results[index].user?.profile_image, let owner = respone.results[index].user?.profile_image.small  else {
                            return
                        }
                        
                        
                        guard let preview_photos = respone.results[index].preview_photos  else {
                            return
                        }
                        
                        for index in 0...preview_photos.count - 1 {
                            
                            guard let detailItemUrl = URL(string: preview_photos[index].urls.small)  else {
                                return
                            }
                            
                            let albumDetailItem = AlbumDetailItem(identifier: preview_photos[index].id, title: title, photoURL: detailItemUrl, thumbnailURL: detailItemUrl, profile_image: profile, urls: preview_photos[index].urls)
                            
                            if !albumDetailItems.contains(albumDetailItem) {
                                albumDetailItems.append(albumDetailItem)
                            }
                            
                        }
                        
                        var isLandscape = false
                        if cover_photo.width > cover_photo.height {
                            isLandscape = true
                        }
                        
                        guard let ownerURL = URL(string: owner) else {
                            return
                        }
                        
                        let albumItem = AlbumItem(albumTitle: "Wallpapers", albumURL: url, ownerTitle: title, ownerURL: ownerURL, isLandscape: isLandscape, imageItems: albumDetailItems)
                        
                        self.sharedAlbumsRespone.value.append(albumItem)
                        
                    }
                    completionHandler(true)
                    
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print(code)
                        default:
                            self.error.value = error
                    }
                    completionHandler(false)
            }
        }
    }
    
    func reset() {
        allCursor = nil
        featureCursor = nil
        shareCursor = nil
        
        unsplashFeaturePagedRequest = nil
        unsplashSharePagedRequest  = nil
        unsplashAllPagedRequest  = nil
    }
}
