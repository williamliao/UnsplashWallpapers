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
    var respone: Observable<Response?> = Observable(nil)
    var isLoading: Observable<Bool> = Observable(false)
    var restultImage: Observable<UIImage?> = Observable(nil)
    var photoInfo: Observable<PhotoInfo?> = Observable(nil)
    
    // MARK: - component
    private var cancellable: AnyCancellable?
    private var isFavorite: Bool = false
    
    var navItem: UINavigationItem!
    let favoriteManager = FavoriteManager.sharedInstance
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

extension DetailViewModel {
    func createBarItem() {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage(systemName: "heart"), for: .normal)
        backButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        backButton.addTarget(self, action: #selector(favoriteAction), for: .touchUpInside)
        navItem.rightBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func favoriteAction() {
        isFavorite = !isFavorite
        let backButton = navItem.rightBarButtonItem?.customView as! UIButton
        backButton.isSelected = isFavorite
        navItem.rightBarButtonItem = UIBarButtonItem(customView: backButton)
        
        guard let photoInfo = photoInfo.value  else {
            return
        }
        
        favoriteManager.handleSaveAction(photo: photoInfo, isFavorite: isFavorite)
    }
    
    func loadFavorite() {
        
        favoriteManager.loadFavorite(key: "favorites") { (success) in
            if (success) {
                guard let photoInfo = photoInfo.value  else {
                    return
                }
                
                if (favoriteManager.favorites.value.contains(photoInfo)) {
                    let backButton = navItem.rightBarButtonItem?.customView as! UIButton
                    backButton.isSelected = true
                    navItem.rightBarButtonItem = UIBarButtonItem(customView: backButton)
                }
            } else {
                
            }
        }
    }
}
