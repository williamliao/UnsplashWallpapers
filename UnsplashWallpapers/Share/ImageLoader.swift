//
//  ImageLoader.swift
//  Jikan
//
//  Created by William Liao on 2021/2/7.
//  Copyright © 2021 William Liao. All rights reserved.
//

import UIKit
import Combine

public final class ImageLoader {
    public static let shared = ImageLoader()

    private var urlSession: URLSession = .shared
    private let cache: ImageCacheType
    private lazy var backgroundQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 30
        return queue
    }()
    
    init(urlSession: URLSession = .shared,
         cache: ImageCacheType = ImageCache()) {
        self.urlSession = urlSession
        self.cache = cache
    }
    
    public func loadImage(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let image = cache[url] {
            //print("load form cache")
            return Just(image).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { (data, response) -> UIImage? in return UIImage(data: data) }
            .catch { error in return Just(nil) }
            .handleEvents(receiveOutput: {[unowned self] image in
                guard let image = image else { return }
                self.cache[url] = image
            })
            //.print("Image loading \(url):")
            .subscribe(on: backgroundQueue)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func publisher(for url: URL) -> AnyPublisher<UIImage, Error> {
        
        guard url.scheme == "https" else {
//            return Fail(error: URLError(.badURL, userInfo: [
//                NSLocalizedFailureReasonErrorKey: """
//                Image loading may only be performed over HTTPS
//                """,
//                NSURLErrorFailingURLErrorKey: url
//            ]))
            return Fail(error: ServerError.invalidURL)
            //.receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        }
        
        if let image = cache[url] {
            return Just(image)
                    .setFailureType(to: Error.self)
                    //.receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        } else {
            return urlSession.dataTaskPublisher(for: url)
                
//                .tryMap { data in
//                    guard let image = UIImage(data: data) else {
//                        throw URLError(.badServerResponse, userInfo: [
//                            NSURLErrorFailingURLErrorKey: url
//                        ])
//                    }
//                    return image
//                }
                .tryMap { response -> (data: Data, response: URLResponse) in
                    guard let httpResponse = response.response as? HTTPURLResponse else {
                          throw ServerError.invalidResponse
                    }
                    
                    if httpResponse.statusCode == 429 {
                        throw ServerError.rateLimitted
                    }

                    if httpResponse.statusCode == 503 {
                        throw ServerError.serverUnavailable
                    }
                    
                    if httpResponse.statusCode == 408 {
                        throw ServerError.timeOut
                    }
                    
                    if httpResponse.statusCode != 200 {
                        throw ServerError.statusCode(httpResponse.statusCode)
                    }
                    
                    let imageData = response.data
                  
                    return (imageData, httpResponse)
                }
//                .tryMap { data -> UIImage in
//                  guard let image = UIImage(data: data) else {
//                    throw ServerError.invalidImage
//                  }
//                  return image
//                }
                .asyncMap { [cache] data in
//                    guard let image = UIImage(data: data) else {
//                        throw ServerError.invalidImage
//                    }
                    
                    guard let image = UIImage(data: data.data) else { throw ServerError.invalidImage }
                    cache[url] = image
                    
                    if let cacheImage = cache[url] {
                        return cacheImage
                    } else {
                        return image
                    }
                }
                .mapError { ServerError.map($0) }
//                .handleEvents(receiveOutput: {[weak self] image in
//                    self?.cache[url] = image
//                })
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
    
    @available(iOS 15.0.0, *)
    func awaitAsync(for url: URL) async throws -> UIImage {
        let (data, response) = try await urlSession.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            
            if let httpURLResponse = response as? HTTPURLResponse {
                throw ServerError.statusCode(httpURLResponse.statusCode)
            } else {
                throw ServerError.invalidResponse
            }
            
        }
        guard let image = UIImage(data: data) else { throw ServerError.invalidImage }
        cache[url] = image
        
        if let cacheImage = cache[url] {
            return cacheImage
        } else {
            return image
        }
    }
    
    func awaitAsyncWithCompletion(for url: URL, completion: @escaping (Result<UIImage, Error>) -> ()) {
        let task = urlSession.dataTask(with: url) { data, response, error in
            guard let responseData = data, error == nil else {
                completion(.failure(error ?? ServerError.badData))
                return
            }
            
            guard let image = UIImage(data: responseData) else {
                completion(.failure(ServerError.invalidImage))
                return
            }
            self.cache[url] = image
            
            if let cacheImage = self.cache[url] {
                completion(.success(cacheImage))
            } else {
                completion(.success(image))
            }
        }
        task.resume()
    }
    
    @available(iOS 13.0.0, *)
    func downloadImageConcurrency(from imageUrl: URL) async throws -> APIResult<UIImage, ServerError> {
       
        do {
            
            if UnsplashAPI.secretKey.isEmpty && UnsplashAPI.accessKey.isEmpty {
                throw ServerError.unAuthorized
            }
            
            return try await withCheckedThrowingContinuation({
                (continuation: CheckedContinuation<(APIResult<UIImage, ServerError>), Error>) in
                
                awaitAsyncWithCompletion(for: imageUrl) { result in
                    
                    switch result {
                    case .success(let image):
                        continuation.resume(returning: APIResult.success(image))
                    case .failure(_):
                        continuation.resume(returning: APIResult.failure(ServerError.invalidImage))
                    }
                }
            })
        } catch  {
            return APIResult.failure(ServerError.unKnown)
        }
    }
    
    func getCacheImage(url: URL) -> UIImage? {
        return cache[url]
    }
}


