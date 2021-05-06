//
//  CollectionListViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import Foundation

class CollectionListViewModel {
    var coordinator: MainCoordinator?
    
    var isLoading: Observable<Bool> = Observable(false)
    var error: Observable<Error?> = Observable(nil)
    private(set) var isFetching = false
    private var canFetchMore = true
    
    let service: UnsplashService = UnsplashService()
    
    var collectionListResponse: Observable<[CollectionResponse]?> = Observable([])
    
    var collectionListCursor: Cursor!
    
    var unsplashCollectionRequest: UnsplashCollectionRequest!
    
    var query: String = ""
}

extension CollectionListViewModel {
    
    func fetchCollection(id:String) {
        service.networkManager = NetworkManager(endPoint: .get_collection)
        
        query = id
        
        isLoading.value = true
        
        if collectionListCursor == nil {
            collectionListCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashCollectionRequest = UnsplashCollectionRequest(with: collectionListCursor)
        }
        
        service.collection(id: id, pageRequest: unsplashCollectionRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    self.collectionListResponse.value = respone
        
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
    
    func fetchNextPage() {
        if isLoading.value {
            return
        }
        
        if canFetchMore == false {
            return
        }
        
        service.networkManager = NetworkManager(endPoint: .get_collection)
        
        
        service.collection(id: query, pageRequest: unsplashCollectionRequest) { [weak self] (result) in
            self?.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    if (respone.count == 0) {
                        return
                    }
                   
                    guard var new = self?.collectionListResponse.value  else {
                        return
                    }
                    
                    for index in 0...respone.count - 1 {
                        
                        if !new.contains(respone[index]) {
                            new.append(respone[index])
                        }
                    }
                   
                    self?.collectionListResponse.value = new
                   
                    guard let cursor = self?.collectionListCursor ,let count = self?.collectionListResponse.value?.count else {
                        return
                    }

                    if count < cursor.perPage {
                        self?.canFetchMore = false
                    } else {
                        self?.collectionListCursor = self?.unsplashCollectionRequest.nextCursor()
                    }
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print(code)
                        default:
                            self?.error.value = error
                    }
            }
        }
    }
}
