//
//  UserProfileViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import Foundation

class UserProfileViewModel {
    var coordinator: MainCoordinator?
    var service: UnsplashService = UnsplashService()
    
    var userPhotosResponse: Observable<[CollectionResponse]?> = Observable([])
    var userLikesResponse: Observable<[CollectionResponse]?> = Observable([])
    var userCollectionsResponse: Observable<[UserCollectionRespone]?> = Observable([])
    
    var isLoading: Observable<Bool> = Observable(false)
    var error: Observable<Error?> = Observable(nil)
    private(set) var isFetching = false
    private var canFetchMore = true
    
    var userProfileInfo: UserProfileInfo!
    
    var userPhotosCursor: Cursor!
    var unsplashUserPhotosdRequest: UnsplashUserListRequest!
    
    var userLikePhotosCursor: Cursor!
    var unsplashUserLikePhotosdRequest: UnsplashUserListRequest!
    
    var userCollectionsPhotosCursor: Cursor!
    var unsplashUserCollectionsPhotosdRequest: UnsplashUserListRequest!
    
    var section: UserProfileCurrentSource = .photos
    
    var query = ""
}

extension UserProfileViewModel {
    func fetchUserPhotos(username: String) {
        service = UnsplashService(endPoint: .user_photo)
        query = username
        isLoading.value = true
        
        if userPhotosCursor == nil {
            userPhotosCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashUserPhotosdRequest = UnsplashUserListRequest(with: userPhotosCursor)
        }
        
        service.listUserPhotos(username: username, pageRequest: unsplashUserPhotosdRequest) { [weak self] (result) in
            self?.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    self?.userPhotosResponse.value = respone
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print("statusCodeError \(code)")
                        default:
                            self?.error.value = error
                    }
            }
        }
    }
    
    func fetchUserLikePhotos(username: String) {
        service = UnsplashService(endPoint: .user_photo)
        query = username
        isLoading.value = true
        
        if userLikePhotosCursor == nil {
            userLikePhotosCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashUserLikePhotosdRequest = UnsplashUserListRequest(with: userLikePhotosCursor)
        }
        
        service.listUserLikePhotos(username: username, pageRequest: unsplashUserLikePhotosdRequest) { [weak self] (result) in
            self?.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    self?.userLikesResponse.value = respone
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print("statusCodeError \(code)")
                        default:
                            self?.error.value = error
                    }
            }
        }
    }
    
    func fetchUserCollectons(username: String) {
        service = UnsplashService(endPoint: .user_photo)
        query = username
        isLoading.value = true
        
        if userCollectionsPhotosCursor == nil {
            userCollectionsPhotosCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashUserCollectionsPhotosdRequest = UnsplashUserListRequest(with: userCollectionsPhotosCursor)
        }
        
        service.listUserCollections(username: username, pageRequest: unsplashUserCollectionsPhotosdRequest) { [weak self] (result) in
            self?.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    self?.userCollectionsResponse.value = respone
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print("statusCodeError \(code)")
                        default:
                            self?.error.value = error
                    }
            }
        }
    }
    
    func fetchNextPage() {
        
        if isLoading.value {
            return
        }
        
        if canFetchMore == false {
            return
        }
        
        isLoading.value = true
        
        switch section {
            case .photos:
                unsplashUserPhotosdRequest = UnsplashUserListRequest(with: userPhotosCursor)
                
                service.listUserPhotos(username: query, pageRequest: unsplashUserPhotosdRequest) { [weak self] (result) in
                    self?.isLoading.value = false
                    switch result {
                        case .success(let respone):
                            
                            if (respone.count == 0) {
                                return
                            }
                           
                            guard var new = self?.userPhotosResponse.value  else {
                                return
                            }
                            
                            for index in 0...respone.count - 1 {
                                
                                if !new.contains(respone[index]) {
                                    new.append(respone[index])
                                }
                            }

                            self?.userPhotosResponse.value = new
                           
                            guard let cursor = self?.userPhotosCursor ,let count = self?.userPhotosResponse.value?.count else {
                                return
                            }

                            if count < cursor.perPage {
                                self?.canFetchMore = false
                            } else {
                                self?.userPhotosCursor = self?.unsplashUserPhotosdRequest.nextCursor()
                            }
                
                        case .failure(let error):
                            
                            switch error {
                                case .statusCodeError(let code):
                                    print("statusCodeError \(code)")
                                default:
                                    self?.error.value = error
                            }
                    }
                }
                
                break
            case .likes:
                unsplashUserLikePhotosdRequest = UnsplashUserListRequest(with: userLikePhotosCursor)
                
                service.listUserLikePhotos(username: query, pageRequest: unsplashUserLikePhotosdRequest) { [weak self] (result) in
                    self?.isLoading.value = false
                    switch result {
                        case .success(let respone):

                            if (respone.count == 0) {
                                return
                            }
                           
                            guard var new = self?.userLikesResponse.value  else {
                                return
                            }
                            
                            for index in 0...respone.count - 1 {
                                
                                if !new.contains(respone[index]) {
                                    new.append(respone[index])
                                }
                            }

                            self?.userLikesResponse.value = new
                           
                            guard let cursor = self?.userLikePhotosCursor ,let count = self?.userLikesResponse.value?.count else {
                                return
                            }

                            if count < cursor.perPage {
                                self?.canFetchMore = false
                            } else {
                                self?.userLikePhotosCursor = self?.unsplashUserLikePhotosdRequest.nextCursor()
                            }
                
                        case .failure(let error):
                            
                            switch error {
                                case .statusCodeError(let code):
                                    print("statusCodeError \(code)")
                                default:
                                    self?.error.value = error
                            }
                    }
                }
                
                break
            case .collections:
                unsplashUserCollectionsPhotosdRequest = UnsplashUserListRequest(with: userCollectionsPhotosCursor)
                
                service.listUserCollections(username: query, pageRequest: unsplashUserCollectionsPhotosdRequest) { [weak self] (result) in
                    self?.isLoading.value = false
                    switch result {
                        case .success(let respone):
                            
                            if (respone.count == 0) {
                                return
                            }
                           
                            guard var new = self?.userCollectionsResponse.value  else {
                                return
                            }
                            
                            for index in 0...respone.count - 1 {
                                
                                if !new.contains(respone[index]) {
                                    new.append(respone[index])
                                }
                            }

                            self?.userCollectionsResponse.value = new
                           
                            guard let cursor = self?.userCollectionsPhotosCursor ,let count = self?.userCollectionsResponse.value?.count else {
                                return
                            }

                            if count < cursor.perPage {
                                self?.canFetchMore = false
                            } else {
                                self?.userCollectionsPhotosCursor = self?.unsplashUserCollectionsPhotosdRequest.nextCursor()
                            }
                
                        case .failure(let error):
                            
                            switch error {
                                case .statusCodeError(let code):
                                    print("statusCodeError \(code)")
                                default:
                                    self?.error.value = error
                            }
                    }
                }
                
                break
        }
    }
    
    func reset() {
        userLikePhotosCursor = nil
        unsplashUserLikePhotosdRequest = nil
        userPhotosCursor = nil
        unsplashUserPhotosdRequest = nil
        userCollectionsPhotosCursor = nil
        unsplashUserCollectionsPhotosdRequest = nil
        userPhotosResponse.value = nil
        userLikesResponse.value = nil
        isFetching = false
        canFetchMore = false
        isLoading.value = false
        query = ""
    }
}
