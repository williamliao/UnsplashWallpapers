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
    
    @available(iOS 15.0.0, *)
    func downloadWithConcurrencyErrorHandler(url: URL, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        Task {
            let image = try await self.loadImageWithConcurrency(for: url)
            
            completionHandler(image, nil)
        }
        
    }
    
    func downloadWithConcurrencyCombineErrorHandler(url: URL) async throws -> APIResult<UIImage, ServerError> {
       /* do {
            let image = try await self.loadImageWithError(for: url)
                .retry(1)
                .singleResult()
            
            return APIResult.success(image)
            
        } catch {
            return APIResult.failure(error as? ServerError ?? ServerError.invalidImage)
        } */
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
        let downloader = ImageLoader(urlSession: session)
        
        do {
            let result = try await downloader.downloadImageConcurrency(from: url)
           
           switch result {
           case .success(let image):
               
               return APIResult.success(image)
               
           case .failure(let error):
               print("configureImage error \(error)")
               
               return APIResult.failure(error)
           }
             
         } catch {
             return APIResult.failure(error as? ServerError ?? ServerError.invalidImage)
         }
    }
    
    @available(iOS 14.0.0, *)
    func downloadWithErrorHandler(url: URL, completionHandler: @escaping (UIImage?, Error?) -> Void) {
        
        cancellable = self.loadImageWithError(for: url)
            .retry(1)
            .sink(receiveCompletion: { (completion) in

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
