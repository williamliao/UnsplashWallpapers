//
//  UnsplashService.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

class UnsplashService: NetworkManager {
    private var loadingTask: Task<Void, Never>?
    //var networkManager: NetworkManager!
}

extension UnsplashService {
    
    @available(iOS 13.0.0, *)
    func fetchWithConcurrency(completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
        guard loadingTask == nil else {
            return
        }
        
        loadingTask = Task {
            let result = try? await fetchDataWithConcurrency(method: .get, decode: { json -> [Response]? in
                guard let feedResult = json as? [Response] else { return  nil }
                return feedResult
            })

            if let returnResult = result {
                completion(returnResult)
            }
        }
        loadingTask = nil
    }
    
    func fetchDataWithNetworkManager(completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
//        self.fetch(method: .get, decode: { json -> [Response]? in
//            guard let feedResult = json as? [Response] else { return  nil }
//            return feedResult
//        }, completion: completion)
    }
    
    @available(iOS 13.0.0, *)
    func searchWithConcurrency(completion: @escaping (APIResult<SearchRespone, ServerError>) -> Void) {
        
        guard loadingTask == nil else {
            return
        }
        
        loadingTask = Task {
            let result = try? await query(method: .get, decode: { json -> SearchRespone? in
                guard let feedResult = json as? SearchRespone else { return  nil }
                return feedResult
            })

            if let returnResult = result {
                completion(returnResult)
            }
        }
        loadingTask = nil
    }
    
    func search(completion: @escaping (APIResult<SearchRespone, ServerError>) -> Void) {
        
        guard loadingTask == nil else {
            return
        }
        
        loadingTask = Task {
            let result = try? await query(method: .get, decode: { json -> SearchRespone? in
                guard let feedResult = json as? SearchRespone else { return  nil }
                return feedResult
            })
            
            if let returnResult = result {
                completion(returnResult)
            }
        }
        loadingTask = nil
    }
    
    func topic(completion: @escaping (APIResult<Topic, ServerError>) -> Void) {
        
        guard loadingTask == nil else {
            return
        }
        
        loadingTask = Task {
            let result = try? await query(method: .get, decode: { json -> Topic? in
                guard let feedResult = json as? Topic else { return  nil }
                return feedResult
            })
            
            if let returnResult = result {
                completion(returnResult)
            }
        }
        loadingTask = nil
    }
    
    func topicPhotos(completion: @escaping (APIResult<Topic, ServerError>) -> Void) {
        guard loadingTask == nil else {
            return
        }
        
        loadingTask = Task {
            let result = try? await query(method: .get, decode: { json -> Topic? in
                guard let feedResult = json as? Topic else { return  nil }
                return feedResult
            })
            
            if let returnResult = result {
                completion(returnResult)
            }
        }
        loadingTask = nil
    }
    
    func listUserPhotos(completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        guard loadingTask == nil else {
            return
        }
        loadingTask = Task {
            let result = try? await query(method: .get, decode: { json -> [CollectionResponse]? in
                guard let feedResult = json as? [CollectionResponse] else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        loadingTask = nil
    }
    
    func listUserLikePhotos(completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        
        guard loadingTask == nil else {
            return
        }
        
        loadingTask = Task {
            let result = try? await query(method: .get, decode: { json -> [CollectionResponse]? in
                guard let feedResult = json as? [CollectionResponse] else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        loadingTask = nil
    }
    
    func listUserCollections(completion: @escaping (APIResult<[UserCollectionRespone], ServerError>) -> Void) {
        
        guard loadingTask == nil else {
            return
        }
        
        loadingTask = Task {
            let result = try? await query(method: .get, decode: { json -> [UserCollectionRespone]? in
                guard let feedResult = json as? [UserCollectionRespone] else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        loadingTask = nil
    }
    
    func collection(completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        
        guard loadingTask == nil else {
            return
        }
        
        loadingTask = Task {
            let result = try? await query(method: .get, decode: { json -> [CollectionResponse]? in
                guard let feedResult = json as? [CollectionResponse] else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        loadingTask = nil
    }
    
    func getPhotoInfo(completion: @escaping (APIResult<UnsplashPhotoInfo, ServerError>) -> Void) {
        
        guard loadingTask == nil else {
            return
        }
        
        loadingTask = Task {
            let result = try? await query(method: .get, decode: { json -> UnsplashPhotoInfo? in
                guard let feedResult = json as? UnsplashPhotoInfo else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        loadingTask = nil
    }
    
    func getAllAlbum(completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
        guard loadingTask == nil else {
            return
        }
        
        loadingTask = Task {
            let result = try? await query(method: .get, decode: { json -> [Response]? in
                guard let feedResult = json as? [Response] else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        loadingTask = nil
    }
    
    func fetchRandomWithQuery(completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
        guard loadingTask == nil else {
            return
        }

        loadingTask = Task {
            
            let result = try? await query(method: .get, decode: { json -> [Response]? in
                guard let feedResult = json as? [Response] else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        loadingTask = nil
    }
    
    func mock(completion: @escaping (APIResult<Data, Error>) -> Void) async {
        do {
            try await getConcurrency { data, response, error in
                
                guard let data = data else {
                    return
                }
                
                completion(APIResult.success(data))
            }
        } catch  {
            
        }
    }
}

extension UnsplashService {
    func cancelTask() {
        loadingTask?.cancel()
        loadingTask = nil
    }
}
