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
    
    func cancel() {
        cancellable?.cancel()
    }
    
    @available(iOS 13.0, *)
    private func loadImage(for url: URL) -> AnyPublisher<UIImage?, Never> {
        return Just(url)
        .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
            return ImageLoader.shared.loadImage(from: url)
        })
        .eraseToAnyPublisher()
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
