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

protocol FetchMoreDataDelegate: AnyObject {
    func realodSection(newData: [Response])
}

class PhotoListViewModel  {
    var coordinator: MainCoordinator?
    
    weak var fetchMoreDataDelegate: FetchMoreDataDelegate?
    
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
    var isInOfflineMode: Observable<Bool> = Observable(false)
    
    var service: UnsplashService = UnsplashService()
    
    var fetchNatureCursor: Cursor!
    var fetchWallpapersCursor: Cursor!
    
    var unsplashNaturePagedRequest: UnsplashSearchPagedRequest!
    var unsplashWallpaperPagedRequest: UnsplashSearchPagedRequest!
  
    var segmentedIndex = SegmentedIndex.random
}

extension PhotoListViewModel {
    
    @available(iOS 15.0.0, *)
    func fetchDataWithConcurrency() {
        service = UnsplashService(endPoint: .random)
        
        isLoading.value = true
        
        service.fetchWithConcurrency { [weak self] (result) in
            
            self?.isLoading.value = false
            
            switch result {
                case .success(let respone):
                   
                    self?.respone.value = respone
        
                case .failure(let error):
                    
                    self?.error.value = error
            }
        }
    }
    
    func fetchData() {
        
        service = UnsplashService(endPoint: .random)
        
        isLoading.value = true
        
        service.fetchDataWithNetworkManager() { (result) in
            self.isLoading.value = false
            
            switch result {
                case .success(let respone):
                   
                    self.respone.value = respone
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print("fetchData statusCodeError \(code)")
                            
                        case .encounteredError(let error):
                            self.error.value = error
                        default:
                            
                            self.error.value = error
                    }
            }
        }
        
        
    }
    
    func fetchNature() {
        service = UnsplashService(endPoint: .search("nature", unsplashNaturePagedRequest))
        
        isLoading.value = true
        
        if fetchNatureCursor == nil {
            fetchNatureCursor = Cursor(query: "", page: 1, perPage: 30, parameters: [:])
            unsplashNaturePagedRequest = UnsplashSearchPagedRequest(with: fetchNatureCursor)
        }
        
        service.search(pageRequest: unsplashNaturePagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                   
                    self.searchRespone.value = respone
                    
                    self.fetchNatureCursor = self.unsplashNaturePagedRequest.nextCursor()
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print("fetchNature statusCodeError \(code)")
                        default:
                            self.error.value = error
                    }
            }
        }
    }
    
    func fetchWallpapers() {
        service = UnsplashService(endPoint: .search("wallpapers", unsplashNaturePagedRequest))
        
        isLoading.value = true
        
        if fetchWallpapersCursor == nil {
            fetchWallpapersCursor = Cursor(query: "", page: 1, perPage: 30, parameters: [:])
            unsplashWallpaperPagedRequest = UnsplashSearchPagedRequest(with: fetchWallpapersCursor)
        }
        
        service.search(pageRequest: unsplashWallpaperPagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                   
                    self.searchRespone.value = respone
                    
                    self.fetchWallpapersCursor = self.unsplashWallpaperPagedRequest.nextCursor()
                    
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print("fetchWallpapers statusCodeError \(code)")
                        default:
                            self.error.value = error
                    }
            }
        }

    }
    
    @available(iOS 15.0.0, *)
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
            
            service.fetchWithConcurrency() { [weak self] (result) in
                self?.isLoading.value = false
                self?.isFetchingNextPage = false
                
                switch result {
                    case .success(let respone):
                        
                        if (respone.count == 0) {
                            return
                        }
                       
                        guard var dataSource = self?.respone.value  else {
                            return
                        }
                    
                        for newValue in respone {
                            if !dataSource.contains(newValue) {
                                dataSource.append(newValue)
                            }
                        }

                        self?.respone.value = dataSource

                        guard let count = self?.respone.value?.count else {
                            return
                        }

                        if count < 10 {
                            self?.canFetchMore = false
                        }
            
                    case .failure(let error):
                        
                        switch error {
                            case .statusCodeError(let code):
                                print("fetchNextPage random statusCodeError \(code)")
                            default:
                                self?.error.value = error
                        }
                }
            }
               
            case .nature:
                unsplashNaturePagedRequest = UnsplashSearchPagedRequest(with: fetchNatureCursor)
                service = UnsplashService(endPoint: .search("nature", unsplashNaturePagedRequest))
            
            service.searchWithConcurrency(pageRequest: unsplashNaturePagedRequest) { [weak self] (result) in
                
                self?.isLoading.value = false
                self?.isFetchingNextPage = false
                
                switch result {
                    case .success(let respone):
                        
                        if (respone.results.count == 0) {
                            return
                        }
                        
                        guard var dataSource = self?.searchRespone.value  else {
                            return
                        }
     
                        dataSource.total = respone.total
                        dataSource.total_pages = respone.total_pages

                        for newValue in respone.results {
                            if !dataSource.results.contains(newValue) {
                                dataSource.results.append(newValue)
                            }
                        }
                        
                        self?.searchRespone.value = dataSource
                        
                        guard let cursor = self?.fetchNatureCursor else {
                            return
                        }
                        
                        if dataSource.results.count < cursor.perPage {
                            self?.canFetchMore = false
                        } else {
                            self?.fetchNatureCursor = self?.unsplashNaturePagedRequest.nextCursor()
                        }
                       
                    case .failure(let error):
                        
                        switch error {
                            case .statusCodeError(let code):
                                print("fetchNextPage nature statusCodeError \(code)")
                            default:
                                self?.error.value = error
                        }
                }
            }
            
                
                
            case .wallpapers:
                unsplashWallpaperPagedRequest = UnsplashSearchPagedRequest(with: fetchWallpapersCursor)
                service = UnsplashService(endPoint: .search("wallpapers", unsplashWallpaperPagedRequest))
                
                //print("fetchWallpapersCursor \(unsplashWallpaperPagedRequest.cursor)")
            
            service.searchWithConcurrency(pageRequest: unsplashWallpaperPagedRequest) { [weak self] (result) in
                self?.isLoading.value = false
                self?.isFetchingNextPage = false
                
                switch result {
                    case .success(let respone):
                       
                        if (respone.results.count == 0) {
                            return
                        }
                        
                        guard var dataSource = self?.searchRespone.value  else {
                            return
                        }
     
                        dataSource.total = respone.total
                        dataSource.total_pages = respone.total_pages

                        for newValue in respone.results {
                            if !dataSource.results.contains(newValue) {
                                dataSource.results.append(newValue)
                            }
                        }
                        
                        self?.searchRespone.value = dataSource
                        
                        guard let cursor = self?.fetchWallpapersCursor else {
                            return
                        }
                        
                        if dataSource.results.count < cursor.perPage {
                            self?.canFetchMore = false
                        } else {
                            self?.fetchWallpapersCursor = self?.unsplashWallpaperPagedRequest.nextCursor()
                        }
            
                    case .failure(let error):
                        
                        switch error {
                            case .statusCodeError(let code):
                                print("fetchNextPage wallpapers statusCodeError \(code)")
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
        
        fetchNatureCursor = nil
        fetchWallpapersCursor = nil

        isLoading.value = false
        self.searchRespone.value = nil
        self.respone.value = nil
       
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
    
    func cancelWhenViewDidDisappear() {
        service.cancelTask()
    }
}


