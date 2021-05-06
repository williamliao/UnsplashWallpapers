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
    private var isFetchingNextPage = false
    
    var isLoading: Observable<Bool> = Observable(false)
    var isSearching: Observable<Bool> = Observable(false)
    
    let service: UnsplashService = UnsplashService()
    
    var fetchCursor: Cursor!
    var fetchNatureCursor: Cursor!
    var fetchWallpapersCursor: Cursor!
    
    var unsplashPagedRequest: UnsplashPagedRequest!
    var unsplashNaturePagedRequest: UnsplashSearchPagedRequest!
    var unsplashWallpaperPagedRequest: UnsplashSearchPagedRequest!
  
    var segmentedIndex = SegmentedIndex.random
}

extension PhotoListViewModel {
    func fetchData() {
        
        service.networkManager = NetworkManager(endPoint: .random)
        
        isLoading.value = true
        
        if fetchCursor == nil {
            fetchCursor = Cursor(query: "", page: 1, perPage: 30, parameters: [:])
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
            fetchNatureCursor = Cursor(query: "", page: 1, perPage: 30, parameters: [:])
            unsplashNaturePagedRequest = UnsplashSearchPagedRequest(with: fetchNatureCursor)
        }
        
        service.search(keyword: "nature", pageRequest: unsplashNaturePagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                   
                    self.searchRespone.value = respone
                    
                    self.fetchNatureCursor = self.unsplashNaturePagedRequest.nextCursor()
        
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
        
        if fetchWallpapersCursor == nil {
            fetchWallpapersCursor = Cursor(query: "", page: 1, perPage: 30, parameters: [:])
            unsplashWallpaperPagedRequest = UnsplashSearchPagedRequest(with: fetchWallpapersCursor)
        }
        
        service.search(keyword: "wallpapers", pageRequest: unsplashWallpaperPagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                   
                    self.searchRespone.value = respone
                    
                    self.fetchWallpapersCursor = self.unsplashWallpaperPagedRequest.nextCursor()
                    
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
        isFetchingNextPage = true
        
        switch segmentedIndex {
            case .random:
                unsplashPagedRequest = UnsplashPagedRequest(with: fetchCursor)
                
                service.fetchDataWithNetworkManager(pageRequest: unsplashPagedRequest) { [weak self] (result) in
                    self?.isLoading.value = false
                    self?.isFetchingNextPage = false
                    
                    switch result {
                        case .success(let respone):
                            
                            if (respone.count == 0) {
                                return
                            }
                           
                            guard var new = self?.respone.value  else {
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
                unsplashNaturePagedRequest = UnsplashSearchPagedRequest(with: fetchNatureCursor)
                
                service.search(keyword: "nature", pageRequest: unsplashNaturePagedRequest) { [weak self] (result) in
                    self?.isLoading.value = false
                    self?.isFetchingNextPage = false
                    
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
                                self?.fetchNatureCursor = self?.unsplashNaturePagedRequest.nextCursor()
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
                
            case .wallpapers:
                unsplashWallpaperPagedRequest = UnsplashSearchPagedRequest(with: fetchWallpapersCursor)
                
                service.search(keyword: "wallpapers", pageRequest: unsplashWallpaperPagedRequest) { [weak self] (result) in
                    self?.isLoading.value = false
                    self?.isFetchingNextPage = false
                    
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
                            
                            guard let cursor = self?.fetchWallpapersCursor else {
                                return
                            }
                            
                            if new.results.count < cursor.perPage {
                                self?.canFetchMore = false
                            } else {
                                self?.fetchWallpapersCursor = self?.unsplashWallpaperPagedRequest.nextCursor()
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
        isFetchingNextPage = false
        canFetchMore = true
        unsplashNaturePagedRequest = nil
        unsplashWallpaperPagedRequest = nil
        
        unsplashPagedRequest = nil
        fetchNatureCursor = nil
        fetchWallpapersCursor = nil
        fetchCursor = nil
        isLoading.value = false
        self.searchRespone.value = nil
        self.respone.value = nil
        
        if fetchCursor == nil {
            fetchCursor = Cursor(query: "", page: 1, perPage: 30, parameters: [:])
            unsplashPagedRequest = UnsplashPagedRequest(with: fetchCursor)
        }
        
        if fetchNatureCursor == nil {
            fetchNatureCursor = Cursor(query: "", page: 1, perPage: 30, parameters: [:])
            unsplashNaturePagedRequest = UnsplashSearchPagedRequest(with: fetchNatureCursor)
        }
        
        if fetchWallpapersCursor == nil {
            fetchWallpapersCursor = Cursor(query: "", page: 1, perPage: 30, parameters: [:])
            unsplashWallpaperPagedRequest = UnsplashSearchPagedRequest(with: fetchWallpapersCursor)
        }
    }
    
    func didCloseSearchFunction() {
        self.isSearching.value = false
        self.searchRespone.value = nil
    }
}


