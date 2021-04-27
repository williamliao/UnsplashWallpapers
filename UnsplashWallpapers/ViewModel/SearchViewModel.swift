//
//  SearchViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/26.
//

import Foundation

class SearchViewModel {
    var searchRespone: Observable<SearchRespone?> = Observable(nil)
    var error: Observable<Error?> = Observable(nil)
    var isLoading: Observable<Bool> = Observable(false)
    
    var isSearching: Observable<Bool> = Observable(false)
    let service: UnsplashService = UnsplashService()
    
    var searchCursor: Cursor!
    var unsplashSearchPagedRequest: UnsplashSearchPagedRequest!
    
    var coordinator: MainCoordinator?
    private(set) var isFetching = false
    private var canFetchMore = true
    
    var query = ""
}

extension SearchViewModel {
   
    func search(keyword: String) {
        isSearching.value = true
        query = keyword
        //self.searchHistory.value.append(keyword)
        
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
        
        //cursor = unsplashPagedRequest.nextCursor()
        unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: searchCursor)
        
        service.search(keyword: query, pageRequest: unsplashSearchPagedRequest) { [weak self] (result) in
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
                    
                    guard let cursor = self?.searchCursor else {
                        return
                    }
                    
                    if new.results.count < cursor.perPage {
                        self?.canFetchMore = false
                    } else {
                        self?.searchCursor = self?.unsplashSearchPagedRequest.nextCursor()
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
    
    func didCloseSearchFunction() {
        isSearching.value = false
        query = ""
        isLoading.value = false
        canFetchMore = false
        searchCursor = nil
    }
}
