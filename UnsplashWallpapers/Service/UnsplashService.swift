//
//  UnsplashService.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

class UnsplashService {
    
    var networkManager: NetworkManager = NetworkManager(resourceURL: .random)
    var respone: Observable<[Response]?> = Observable(nil)
    var error: Observable<Error?> = Observable(nil)
}

extension UnsplashService {
    
    func fetchData() {
        fetchDataWithNetworkManager { (result) in
            switch result {
                case .success(let user):
                   
                    self.respone.value = user
        
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
   
    private func fetchDataWithNetworkManager(completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
        let request = networkManager.createURLRequest(method: .get)
        
        networkManager.fetch(with: request as URLRequest , decode: { json -> [Response]? in
            guard let feedResult = json as? [Response] else { return  nil }
            return feedResult
        }, completion: completion)
    }
}
