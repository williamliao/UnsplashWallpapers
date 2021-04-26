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
    
    
    var unsplashPagedRequest: UnsplashPagedRequest!
    var unsplashSearchPagedRequest: UnsplashSearchPagedRequest!
    var unsplashTopicRequest: UnsplashTopicRequest!
    
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
        service.networkManager = NetworkManager(endPoint: .nature)
        
        isLoading.value = true
        
        if fetchNatureCursor == nil {
            fetchNatureCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashTopicRequest = UnsplashTopicRequest(with: fetchNatureCursor)
        }
        
        service.topic(keyword: "nature", pageRequest: unsplashTopicRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    self.natureTopic.value = respone
        
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
        service.networkManager = NetworkManager(endPoint: .wallpapers)
        
        isLoading.value = true
        
        if fetchWallpapersCursor == nil {
            fetchWallpapersCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashTopicRequest = UnsplashTopicRequest(with: fetchWallpapersCursor)
        }
        
        service.topic(keyword: "wallpapers", pageRequest: unsplashTopicRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    self.wallpapersTopic.value = respone
        
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
    
    func search(keyword: String) {
        isSearching.value = true
        
        service.networkManager = NetworkManager(endPoint: .search)
        
        if searchCursor == nil {
            searchCursor = Cursor(query: keyword, page: 1, perPage: 10, parameters: [:])
            unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: searchCursor)
        }
        
        isLoading.value = true
        
        service.search(keyword: unsplashSearchPagedRequest.cursor.query ?? "", pageRequest: unsplashSearchPagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                   
                    self.searchRespone.value = respone
        
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
        
        unsplashPagedRequest = UnsplashPagedRequest(with: fetchCursor)
        
        service.fetchDataWithNetworkManager(pageRequest: unsplashPagedRequest) { [weak self] (result) in
            self?.isLoading.value = false
            switch result {
                case .success(let respone):
                   
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
        
    }
    
    func reset() {
        isFetching = false
        canFetchMore = true
    }
    
    func didCloseSearchFunction() {
        self.isSearching.value = false
        self.searchRespone.value = nil
    }
}


