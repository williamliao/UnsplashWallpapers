//
//  ImageCombineDownloader.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import UIKit
import Combine

protocol ImageDownLoader {
    func download(url: URL, completionHandler: @escaping (UIImage?) -> Void)
}


class ImageCombineDownloader: ImageDownLoader {
    
    private var cancellable: AnyCancellable?
    
    func download(url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        cancellable = self.loadImage(for: url).sink { image in
            DispatchQueue.main.async {
                guard let image = image else {
                    return
                }
                
                completionHandler(image)
            }
        }
    }
    
    func cancel() {
        cancellable?.cancel()
    }

    private func loadImage(for url: URL) -> AnyPublisher<UIImage?, Never> {
        return Just(url)
        .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
            return ImageLoader.shared.loadImage(from: url)
        })
        .eraseToAnyPublisher()
    }
}
