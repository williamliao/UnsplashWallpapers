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
    var error: Observable<ServerError?> = Observable(nil)
    
    var service: UnsplashService = UnsplashService()
    
    var featureCursor: Cursor!
    var shareCursor: Cursor!
    var allCursor: Cursor!
    
    var unsplashFeaturePagedRequest: UnsplashSearchPagedRequest!
    var unsplashSharePagedRequest: UnsplashSearchPagedRequest!
    var unsplashAllPagedRequest: UnsplashSearchPagedRequest!
    
}

// MARK: - Public
extension AlbumsViewModel {
    
    func getAllAlbums(completionHandler: @escaping (Bool) -> Void) {
        
        if allCursor == nil {
            allCursor = Cursor(query: "cat", page: 1, perPage: 10, parameters: [:])
            unsplashAllPagedRequest = UnsplashSearchPagedRequest(with: allCursor)
        }
        
        service = UnsplashService(endPoint: .collections("cat", unsplashAllPagedRequest))
        
        isLoading.value = true
        
        if #available(iOS 15.0.0, *) {
            service.searchWithConcurrency(pageRequest: unsplashAllPagedRequest) { (result) in
                self.isLoading.value = false
                switch result {
                    case .success(let respone):
                        
                        self.handleAllRespone(respone: respone)
                        
                        completionHandler(true)
            
                    case .failure(let error):
                        
                        self.handleError(error: error)
                        
                        completionHandler(false)
                }
            }
        } else {
            service.search(pageRequest: unsplashAllPagedRequest) { (result) in
                self.isLoading.value = false
                switch result {
                    case .success(let respone):
                        
                    self.handleAllRespone(respone: respone)
                        
                        completionHandler(true)
            
                    case .failure(let error):
                        
                    self.handleError(error: error)
                        
                        completionHandler(false)
                }
            }
        }
    }
    
    func getFeaturedAlbums(completionHandler: @escaping (Bool) -> Void) {
        
        if featureCursor == nil {
            featureCursor = Cursor(query: "nature", page: 1, perPage: 10, parameters: [:])
            unsplashFeaturePagedRequest = UnsplashSearchPagedRequest(with: featureCursor)
        }
        
        service = UnsplashService(endPoint: .collections("nature", unsplashFeaturePagedRequest))
        
        isLoading.value = true
        
        if #available(iOS 15.0.0, *) {
            service.searchWithConcurrency(pageRequest: unsplashFeaturePagedRequest) { (result) in
                self.isLoading.value = false
                switch result {
                    case .success(let respone):
                        
                        self.handleFeaturedRespone(respone: respone)
                        completionHandler(true)
                        
                    case .failure(let error):

                        self.handleError(error: error)
                        completionHandler(false)
                }
            }
        } else {
            service.search(pageRequest: unsplashFeaturePagedRequest) { (result) in
                self.isLoading.value = false
                switch result {
                    case .success(let respone):
                        
                        self.handleFeaturedRespone(respone: respone)
                        completionHandler(true)
                        
                    case .failure(let error):
                        
                        self.handleError(error: error)
                        completionHandler(false)
                }
            }
        }
    }
    
    func getSharedAlbums(completionHandler: @escaping (Bool) -> Void) {
        
        if shareCursor == nil {
            shareCursor = Cursor(query: "wallpapers", page: 1, perPage: 10, parameters: [:])
            unsplashSharePagedRequest = UnsplashSearchPagedRequest(with: shareCursor)
        }
        
        service = UnsplashService(endPoint: .collections("wallpapers", unsplashSharePagedRequest))
        
        isLoading.value = true
        
        if #available(iOS 15.0.0, *) {
            service.searchWithConcurrency(pageRequest: unsplashSharePagedRequest) { (result) in
                self.isLoading.value = false
                switch result {
                    case .success(let respone):
                        
                        self.handleShareRespone(respone: respone)
                        completionHandler(true)
                        
                    case .failure(let error):
                        
                        self.handleError(error: error)
                        completionHandler(false)
                }
            }
        } else {
            service.search(pageRequest: unsplashSharePagedRequest) { (result) in
                self.isLoading.value = false
                switch result {
                    case .success(let respone):
                        
                        self.handleShareRespone(respone: respone)
                        completionHandler(true)
                        
                    case .failure(let error):
                        
                        self.handleError(error: error)
                        completionHandler(false)
                }
            }
        }
    }
}

// MARK: - Private
extension AlbumsViewModel {
    
    func handleShareRespone(respone: SearchRespone) {
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
    }
    
    func handleFeaturedRespone(respone: SearchRespone) {
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
    }
    
    func handleAllRespone(respone: SearchRespone) {
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
    }
    
    func handleError(error: ServerError) {
        switch error {
            case .statusCodeError(let code):
                print(code)
            default:
                
                self.error.value = error
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
    
    func cancelWhenViewDidDisappear() {
        service.cancelTask()
    }
}
