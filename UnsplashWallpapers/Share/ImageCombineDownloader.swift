//
//  ImageCombineDownloader.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import UIKit
#if canImport(Combine)
import Combine
#endif

protocol ImageDownLoader {
    func download(url: URL, completionHandler: @escaping (UIImage?) -> Void)
}


class ImageCombineDownloader: ImageDownLoader {
    
    private var cancellable: AnyCancellable?
    var didReceiveValue = false
    
    func download(url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        
        if #available(iOS 13.0, *) {
            
            cancellable = self.loadImage(for: url).sink { image in
                DispatchQueue.main.async {
                    guard let image = image else {
                        return
                    }
                    
                    completionHandler(image)
                }
            }
        } else {
            downloadImage(from: url) { (image) in
                DispatchQueue.main.async {
                    guard let image = image else {
                        return
                    }
                    
                    completionHandler(image)
                }
            }
        }
    }
    
    @available(iOS 14.0.0, *)
    func downloadWithConcurrencyErrorHandler(url: URL) async throws -> APIResult<UIImage, ServerError> {
        // Only Call This for one Time
        try Task.checkCancellation()
        return try await withCheckedThrowingContinuation({
            (continuation: CheckedContinuation<(APIResult<UIImage, ServerError>), Error>) in
           
            cancellable = self.loadImageWithError(for: url).sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        continuation.resume(throwing: error)
                        print("❗️ failure: \(error)")
                    case .finished:
                            if !self.didReceiveValue {
                                continuation.resume(
                                    throwing: ServerError.badData
                                )
                            }
                        print("🏁 finished")
                    }
                },
                receiveValue: { image in
                    DispatchQueue.main.async {
                        guard !self.didReceiveValue else { return }
                        
                        self.cancellable?.cancel()
                        self.didReceiveValue = true
                        continuation.resume(returning: APIResult.success(image))
                    }
                }
            )
        })
    }
    
    @available(iOS 14.0.0, *)
    func downloadWithErrorHandler(url: URL, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        
        cancellable = self.loadImageWithError(for: url).sink(receiveCompletion: { (completion) in

            switch completion {
                case .finished:
                    //print("🏁 finished")
                    break
                case .failure(let error):
                    print("❗️ failure: \(error)")
                    completionHandler(nil, error)
            }

        }, receiveValue: { (image) in
            DispatchQueue.main.async {
                completionHandler(image, nil)
            }
        })
    }
    
    func downloadWithOldErrorHandler(url: URL, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        getData(from: url) { data, response, error in

            guard error == nil else {
                completionHandler(nil, error)
                return
            }

            guard let data = data else {
                return
            }

            DispatchQueue.main.async() {
                completionHandler(UIImage(data: data), nil)
            }
        }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    @available(iOS 13.0, *)
    func loadImage(for url: URL) -> AnyPublisher<UIImage?, Never> {
        return Just(url)
        .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
            return ImageLoader.shared.loadImage(from: url)
        })
        .eraseToAnyPublisher()
    }
    
    @available(iOS 14.0, *)
    func loadImageWithError(for url: URL) -> AnyPublisher<UIImage, Error> {
        return Just(url)
        .flatMap({ poster -> AnyPublisher<UIImage, Error> in
            return ImageLoader.shared.publisher(for: poster)
        })
        .eraseToAnyPublisher()
    }
    
    @available(iOS 15.0, *)
    func loadImageWithConcurrency(for url: URL) async throws -> UIImage {
        do {
            let image = try await ImageLoader.shared.awaitAsync(for: url)
            return image
        } catch  {
            throw ServerError.invalidImage
        }
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func downloadImage(from url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                completionHandler(UIImage(data: data))
            }
        }
    }
  
    
}
