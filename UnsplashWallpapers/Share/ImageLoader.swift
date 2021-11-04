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

    private let urlSession: URLSession
    private let cache: ImageCacheType
    private lazy var backgroundQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
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
            return Fail(error: URLError(.badURL, userInfo: [
                NSLocalizedFailureReasonErrorKey: """
                Image loading may only be performed over HTTPS
                """,
                NSURLErrorFailingURLErrorKey: url
            ]))
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        }
        
        if let image = cache[url] {
            return Just(image)
                    .setFailureType(to: Error.self)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
        } else {
            return urlSession.dataTaskPublisher(for: url)
                .map(\.data)
                .tryMap { data in
                    guard let image = UIImage(data: data) else {
                        throw URLError(.badServerResponse, userInfo: [
                            NSURLErrorFailingURLErrorKey: url
                        ])
                    }
                    return image
                }
                .handleEvents(receiveOutput: {[weak self] image in
                    self?.cache[url] = image
                })
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        }
    }
    
    func getCacheImage(url: URL) -> UIImage? {
        return cache[url]
    }
}
