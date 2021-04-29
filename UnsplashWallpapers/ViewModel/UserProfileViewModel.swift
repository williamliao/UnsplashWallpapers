//
//  UserProfileViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import Foundation

class UserProfileViewModel {
    var coordinator: MainCoordinator?
    let service: UnsplashService = UnsplashService()
    
    var userPhotosResponse: Observable<[CollectionResponse]?> = Observable([])
    var userLikesResponse: Observable<[CollectionResponse]?> = Observable([])
    
    var isLoading: Observable<Bool> = Observable(false)
    var error: Observable<Error?> = Observable(nil)
    private(set) var isFetching = false
    private var canFetchMore = true
    
    var userProfileInfo: UserProfileInfo!
    
    var userPhotosCursor: Cursor!
    var unsplashUserPhotosdRequest: UnsplashUserListRequest!
    
    var userLikePhotosCursor: Cursor!
    var unsplashUserLikePhotosdRequest: UnsplashUserListRequest!
    
    //var segmentedIndex = SegmentedIndex.random
}

extension UserProfileViewModel {
    func fetchUserPhotos(username: String) {
        service.networkManager = NetworkManager(endPoint: .user_photo)
        
        isLoading.value = true
        
        if userPhotosCursor == nil {
            userPhotosCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashUserPhotosdRequest = UnsplashUserListRequest(with: userPhotosCursor)
        }
        
        service.listUserPhotos(username: username, pageRequest: unsplashUserPhotosdRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    self.userPhotosResponse.value = respone
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print("statusCodeError \(code)")
                        default:
                            self.error.value = error
                    }
            }
        }
    }
    
    func fetchUserLikePhotos(username: String) {
        service.networkManager = NetworkManager(endPoint: .user_photo)
        
        isLoading.value = true
        
        if userLikePhotosCursor == nil {
            userLikePhotosCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashUserLikePhotosdRequest = UnsplashUserListRequest(with: userLikePhotosCursor)
        }
        
        service.listUserLikePhotos(username: username, pageRequest: unsplashUserPhotosdRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    self.userLikesResponse.value = respone
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print("statusCodeError \(code)")
                        default:
                            self.error.value = error
                    }
            }
        }
    }
    
    func fetchNextPage() {
        
    }
    
    func reset() {
        userLikePhotosCursor = nil
        unsplashUserLikePhotosdRequest = nil
        userPhotosCursor = nil
        unsplashUserPhotosdRequest = nil
        userPhotosResponse.value = nil
        userLikesResponse.value = nil
        isFetching = false
        canFetchMore = false
        isLoading.value = false
    }
}
