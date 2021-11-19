//
//  UnsplashService.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

class UnsplashService: NetworkManager {
    
    //var networkManager: NetworkManager!
}

extension UnsplashService {
    
    @available(iOS 15.0.0, *)
    func fetchWithConcurrency(completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        Task {
            let result = try? await fetchDataWithConcurrency(method: .get, decode: { json -> [Response]? in
                guard let feedResult = json as? [Response] else { return  nil }
                return feedResult
            })

            if let returnResult = result {
                completion(returnResult)
            }
        }
    }
    
    func fetchDataWithNetworkManager(completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
//        self.fetch(method: .get, decode: { json -> [Response]? in
//            guard let feedResult = json as? [Response] else { return  nil }
//            return feedResult
//        }, completion: completion)
    }
    
    @available(iOS 15.0.0, *)
    func searchWithConcurrency(pageRequest: UnsplashSearchPagedRequest, completion: @escaping (APIResult<SearchRespone, ServerError>) -> Void) {
        
        Task {
            let result = try? await queryWithConcurrency(pageRequest: pageRequest, method: .get, decode: { json -> SearchRespone? in
                guard let feedResult = json as? SearchRespone else { return  nil }
                return feedResult
            })

            if let returnResult = result {
                completion(returnResult)
            }
        }
    }
    
    func search(pageRequest: UnsplashSearchPagedRequest, completion: @escaping (APIResult<SearchRespone, ServerError>) -> Void) {
        
        Task {
            let result = try? await query(pageRequest: pageRequest, method: .get, decode: { json -> SearchRespone? in
                guard let feedResult = json as? SearchRespone else { return  nil }
                return feedResult
            })
            
            if let returnResult = result {
                completion(returnResult)
            }
        }
        
    }
    
    func topic(id: String, pageRequest: UnsplashTopicRequest, completion: @escaping (APIResult<Topic, ServerError>) -> Void) {
        Task {
            let result = try? await topic(id: id, pageRequest: pageRequest, method: .get, decode: { json -> Topic? in
                guard let feedResult = json as? Topic else { return  nil }
                return feedResult
            })
            
            if let returnResult = result {
                completion(returnResult)
            }
        }
        
    }
    
    func topicPhotos(id: String, pageRequest: UnsplashTopicRequest, completion: @escaping (APIResult<Topic, ServerError>) -> Void) {
        Task {
            let result = try? await topic(id: id, pageRequest: pageRequest, method: .get, decode: { json -> Topic? in
                guard let feedResult = json as? Topic else { return  nil }
                return feedResult
            })
            
            if let returnResult = result {
                completion(returnResult)
            }
        }
        
    }
    
    func listUserPhotos(pageRequest: UnsplashUserListRequest, completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        Task {
            let result = try? await listUserData(pageRequest: pageRequest, method: .get, decode: { json -> [CollectionResponse]? in
                guard let feedResult = json as? [CollectionResponse] else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        
    }
    
    func listUserLikePhotos(username: String, pageRequest: UnsplashUserListRequest, completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        Task {
            let result = try? await listUserData(pageRequest: pageRequest, method: .get, decode: { json -> [CollectionResponse]? in
                guard let feedResult = json as? [CollectionResponse] else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        
    }
    
    func listUserCollections(username: String, pageRequest: UnsplashUserListRequest, completion: @escaping (APIResult<[UserCollectionRespone], ServerError>) -> Void) {
        Task {
            let result = try? await listUserData(pageRequest: pageRequest, method: .get, decode: { json -> [UserCollectionRespone]? in
                guard let feedResult = json as? [UserCollectionRespone] else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        
    }
    
    func collection(pageRequest: UnsplashCollectionRequest, completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        Task {
            let result = try? await get_Collection(pageRequest: pageRequest, method: .get, decode: { json -> [CollectionResponse]? in
                guard let feedResult = json as? [CollectionResponse] else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        
    }
    
    func getPhotoInfo(pageRequest: UnsplashUserPhotoRequest, completion: @escaping (APIResult<UnsplashPhotoInfo, ServerError>) -> Void) {
        Task {
            let result = try? await getPhotoInfo(pageRequest: pageRequest, method: .get, decode: { json -> UnsplashPhotoInfo? in
                guard let feedResult = json as? UnsplashPhotoInfo else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        
    }
    
    func getAllAlbum(pageRequest: UnsplashAlbumsRequest, completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        Task {
            let result = try? await getAlbum(pageRequest: pageRequest, method: .get, decode: { json -> [Response]? in
                guard let feedResult = json as? [Response] else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        
    }
    
    func fetchRandomWithQuery(query: String, pageRequest: UnsplashPagedRequest, completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
      
        Task {
            let result = try? await queryWithRandom(query: query, pageRequest: pageRequest, method: .get, decode: { json -> [Response]? in
                guard let feedResult = json as? [Response] else { return  nil }
                return feedResult
            })
            if let returnResult = result {
                completion(returnResult)
            }
        }
        
    }
    
    func mock(completion: @escaping (APIResult<Data, Error>) -> Void) {
        
        
    }
}
