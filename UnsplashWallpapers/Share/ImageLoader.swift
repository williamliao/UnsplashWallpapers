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
            return Fail(error: ServerError.badURL)
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
                .tryMap { response -> Data in
                  guard
                    let httpURLResponse = response.response as? HTTPURLResponse,
                    httpURLResponse.statusCode == 200
                    else {
                        let httpURLResponse = response.response as? HTTPURLResponse
                        throw ServerError.statusCode(httpURLResponse?.statusCode ?? 500)
                  }
                  
                  return response.data
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
                    guard let image = UIImage(data: data) else { throw ServerError.invalidImage }
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
            let httpURLResponse = response as? HTTPURLResponse
            throw ServerError.statusCode(httpURLResponse?.statusCode ?? 500)
        }
        guard let image = UIImage(data: data) else { throw ServerError.invalidImage }
        cache[url] = image
        
        if let cacheImage = cache[url] {
            return cacheImage
        } else {
            return image
        }
    }
    
    func awaitAsyncWithCompletion(for url: URL, completion: @escaping (Result<UIImage, Error>) -> ()) async throws {
        let task = await urlSession.dataTask(with: url) { data, response, error in
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
    
    func getCacheImage(url: URL) -> UIImage? {
        return cache[url]
    }
}

extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}

@available(iOS 14.0.0, *)
extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async throws -> T
    ) -> Publishers.FlatMap<Future<T, Error>,
                            Publishers.SetFailureType<Self, Error>> {
        flatMap { value in
            Future { promise in
                Task {
                    do {
                        let output = try await transform(value)
                        promise(.success(output))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}

extension Publishers {
    struct MissingOutputError: Error {}
}

extension Publisher {
    func singleResult() async throws -> Output {
        var cancellable: AnyCancellable?
        var didReceiveValue = false

        return try await withCheckedThrowingContinuation { continuation in
            cancellable = sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    case .finished:
                        if !didReceiveValue {
                            continuation.resume(
                                throwing: Publishers.MissingOutputError()
                            )
                        }
                    }
                },
                receiveValue: { value in
                    guard !didReceiveValue else { return }

                    didReceiveValue = true
                    cancellable?.cancel()
                    continuation.resume(returning: value)
                }
            )
        }
    }
}
