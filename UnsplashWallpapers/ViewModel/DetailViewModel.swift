//
//  DetailViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/22.
//

import UIKit
import Combine

class DetailViewModel {
    // MARK:- property
    var respone: Observable<UnsplashPhoto?> = Observable(nil)
    var isLoading: Observable<Bool> = Observable(false)
    var restultImage: Observable<UIImage?> = Observable(nil)
    
    // MARK: - component
    private var cancellable: AnyCancellable?
}

// MARK: - Public
extension DetailViewModel {
     func configureImage(with url: URL) {
        isLoading.value = true
        restultImage.value = nil
        cancellable = self.loadImage(for: url).sink { [unowned self] image in
            isLoading.value = false
            restultImage.value = image
         }
     }
    
    private func loadImage(for url: URL) -> AnyPublisher<UIImage?, Never> {
        return Just(url)
        .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
            return ImageLoader.shared.loadImage(from: url)
        })
        .eraseToAnyPublisher()
    }
}
