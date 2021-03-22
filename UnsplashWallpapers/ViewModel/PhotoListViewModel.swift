//
//  PhotoListViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

class PhotoListViewModel  {
    var coordinator: MainCoordinator?
    var respone: Observable<[UnsplashPhoto]?> = Observable([])
    var searchRespone: Observable<SearchRespone?> = Observable(nil)
   // var respone: Observable<Response?> = Observable(nil)
    var error: Observable<Error?> = Observable(nil)
    private(set) var isFetching = false
    private var canFetchMore = true
    
    var isLoading: Observable<Bool> = Observable(false)
    
    var isSearching: Observable<Bool> = Observable(false)
    let service: UnsplashService = UnsplashService()
    
    var cursor: Cursor!
    var unsplashPagedRequest: UnsplashPagedRequest!
}

extension PhotoListViewModel {
    func fetchData() {
        
        service.networkManager = NetworkManager(endPoint: .random)
        
        service.fetchDataWithNetworkManager { (result) in
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
    
    func search(keyword: String) {
        isSearching.value = true
        
        service.networkManager = NetworkManager(endPoint: .search)
        
        if cursor == nil {
            cursor = Cursor(query: keyword, page: 1, perPage: 10, parameters: [:])
            unsplashPagedRequest = UnsplashPagedRequest(with: cursor)
        }
        
        service.search(keyword: unsplashPagedRequest.cursor.query, pageRequest: unsplashPagedRequest) { (result) in
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
//        if isFetching {
//            return
//        }
//        
//        if canFetchMore == false {
//            return
//        }
//        
//        isFetching = true
        
        if isSearching.value {
            
            cursor = unsplashPagedRequest.nextCursor()
            unsplashPagedRequest = UnsplashPagedRequest(with: cursor)
            
            service.search(keyword: "nature", pageRequest: unsplashPagedRequest) { [weak self] (result) in
                self?.isLoading.value = false
                
                switch result {
                    case .success(let respone):
                       
                        guard var new = self?.searchRespone.value  else {
                            return
                        }
                        
                        new.total = respone.total
                        new.total_pages = respone.total_pages
                        new.results.append(contentsOf: respone.results)
                        
                    
                        self?.searchRespone.value = new
                        
                        
            
                    case .failure(let error):
                        
                        switch error {
                            case .statusCodeError(let code):
                                print(code)
                            default:
                                self?.error.value = error
                        }
                }
            }
        } else {
            
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


