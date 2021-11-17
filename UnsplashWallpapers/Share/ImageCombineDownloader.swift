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
    
    func downloadWithErrorHandler(url: URL, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        
        if #available(iOS 13.0, *) {
            
//            Task {
//                let image = try await loadImageWithConcurrency(for: url)
//                DispatchQueue.main.async {
//                    completionHandler(image, nil)
//                }
//            }
            
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
        } else {
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
    
    @available(iOS 13.0, *)
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
