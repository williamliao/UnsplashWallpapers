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
}

extension SearchViewModel {
   
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
}
