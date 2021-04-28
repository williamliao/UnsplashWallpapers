//
//  PhotoListViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

enum SegmentedIndex: Int, CaseIterable {
    case random
    case nature
    case wallpapers
}

class PhotoListViewModel  {
    var coordinator: MainCoordinator?
    
    var respone: Observable<[Response]?> = Observable([])
    var searchRespone: Observable<SearchRespone?> = Observable(nil)
    var collectionResponse: Observable<[CollectionResponse]?> = Observable([])
    
    var natureTopic: Observable<[Topic]?> = Observable([])
    var wallpapersTopic: Observable<[Topic]?> = Observable([])
    
    var error: Observable<Error?> = Observable(nil)
    private(set) var isFetching = false
    private var canFetchMore = true
    
    var isLoading: Observable<Bool> = Observable(false)
    
    var isSearching: Observable<Bool> = Observable(false)
    let service: UnsplashService = UnsplashService()
    
    var searchCursor: Cursor!
    var fetchCursor: Cursor!
    var fetchNatureCursor: Cursor!
    var fetchWallpapersCursor: Cursor!
    var collectionCursor: Cursor!
    
    var unsplashPagedRequest: UnsplashPagedRequest!
    var unsplashSearchPagedRequest: UnsplashSearchPagedRequest!
    
    var unsplashTopicRequest: UnsplashTopicRequest!
    var unsplashCollectionRequest: UnsplashCollectionRequest!
    
    var segmentedIndex = SegmentedIndex.random
}

extension PhotoListViewModel {
    func fetchData() {
        
        service.networkManager = NetworkManager(endPoint: .random)
        
        isLoading.value = true
        
        if fetchCursor == nil {
            fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashPagedRequest = UnsplashPagedRequest(with: fetchCursor)
        }
        
        service.fetchDataWithNetworkManager(pageRequest: unsplashPagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                   
                    self.respone.value = respone
        
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
    
    func fetchNature() {
        service.networkManager = NetworkManager(endPoint: .search)
        
        isLoading.value = true
        
        if fetchNatureCursor == nil {
            fetchNatureCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: fetchNatureCursor)
        }
        
        service.search(keyword: "nature", pageRequest: unsplashSearchPagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                   
                    self.searchRespone.value = respone
                    
                    self.fetchNatureCursor = self.unsplashSearchPagedRequest.nextCursor()
        
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
    
    func fetchWallpapers() {
        service.networkManager = NetworkManager(endPoint: .search)
        
        isLoading.value = true
        
        if collectionCursor == nil {
            collectionCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: collectionCursor)
        }
        
        service.search(keyword: "wallpapers", pageRequest: unsplashSearchPagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                   
                    self.searchRespone.value = respone
                    
                    self.collectionCursor = self.unsplashSearchPagedRequest.nextCursor()
        
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
    
    func fetchCollection(id:String) {
        service.networkManager = NetworkManager(endPoint: .get_collection)
        
        isLoading.value = true
        
        if fetchWallpapersCursor == nil {
            fetchWallpapersCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashCollectionRequest = UnsplashCollectionRequest(with: fetchWallpapersCursor)
        }
        
        service.collection(id: id, pageRequest: unsplashCollectionRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    self.collectionResponse.value = respone
        
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
        
        isLoading.value = true
        
        switch segmentedIndex {
            case .random:
                unsplashPagedRequest = UnsplashPagedRequest(with: fetchCursor)
                
                service.fetchDataWithNetworkManager(pageRequest: unsplashPagedRequest) { [weak self] (result) in
                    self?.isLoading.value = false
                    switch result {
                        case .success(let respone):
                            
                            if (respone.count == 0) {
                                return
                            }
                           
                            guard var new = self?.respone.value  else {
                                return
                            }
                            
                            if new.count == respone.count {
                               self?.canFetchMore = false
                                return
                            }
                            
                            new.append(contentsOf: respone)
                            
                            self?.respone.value = new
                           
                            guard let cursor = self?.fetchCursor ,let count = self?.respone.value?.count else {
                                return
                            }

                            if count < cursor.perPage {
                                self?.canFetchMore = false
                            } else {
                                self?.fetchCursor = self?.unsplashPagedRequest.nextCursor()
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
                
            case .nature:
                unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: fetchNatureCursor)
                
                service.search(keyword: "nature", pageRequest: unsplashSearchPagedRequest) { [weak self] (result) in
                    self?.isLoading.value = false
                    switch result {
                        case .success(let respone):
                            
                            if (respone.results.count == 0) {
                                return
                            }
                            
                            guard var new = self?.searchRespone.value  else {
                                return
                            }
         
                            new.total = respone.total
                            new.total_pages = respone.total_pages
                            new.results.append(contentsOf: respone.results)
                            
                            self?.searchRespone.value = new
                           
                            guard let cursor = self?.fetchNatureCursor else {
                                return
                            }
                            
                            if new.results.count < cursor.perPage {
                                self?.canFetchMore = false
                            } else {
                                self?.fetchNatureCursor = self?.unsplashSearchPagedRequest.nextCursor()
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
                
                /*service.topic(keyword: "nature", pageRequest: unsplashTopicRequest) */
                
            case .wallpapers:
                unsplashPagedRequest = UnsplashPagedRequest(with: collectionCursor)
                
                service.search(keyword: "wallpapers", pageRequest: unsplashSearchPagedRequest) { [weak self] (result) in
                    self?.isLoading.value = false
                    switch result {
                        case .success(let respone):
                           
                            if (respone.results.count == 0) {
                                return
                            }
                            
                            guard var new = self?.searchRespone.value  else {
                                return
                            }
         
                            new.total = respone.total
                            new.total_pages = respone.total_pages
                            new.results.append(contentsOf: respone.results)
                            
                            self?.searchRespone.value = new
                           
                            guard let cursor = self?.collectionCursor else {
                                return
                            }
                            
                            if new.results.count < cursor.perPage {
                                self?.canFetchMore = false
                            } else {
                                self?.collectionCursor = self?.unsplashSearchPagedRequest.nextCursor()
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
    
    func reset() {
        isFetching = false
        canFetchMore = true
        unsplashSearchPagedRequest = nil
        unsplashPagedRequest = nil
        collectionCursor = nil
        fetchNatureCursor = nil
        fetchCursor = nil
        isLoading.value = false
        self.searchRespone.value = nil
    }
    
    func didCloseSearchFunction() {
        self.isSearching.value = false
        self.searchRespone.value = nil
    }
}


