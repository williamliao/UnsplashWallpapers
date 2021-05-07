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
    var photoRespone: Observable<UnsplashPhotoInfo?> = Observable(nil)
    var isLoading: Observable<Bool> = Observable(false)
    var error: Observable<Error?> = Observable(nil)
    var restultImage: Observable<UIImage?> = Observable(nil)
    var photoInfo: Observable<PhotoInfo?> = Observable(nil)
    
    // MARK: - component
    private var cancellable: AnyCancellable?
    private var isFavorite: Bool = false
    var coordinator: MainCoordinator?
    
    var navItem: UINavigationItem!
    let favoriteManager = FavoriteManager.sharedInstance
    
    var service: UnsplashService = UnsplashService()
    
    var userPhotosCursor: Cursor!
    var unsplashUserPhotosdRequest: UnsplashUserPhotoRequest!

}

// MARK: - Public
extension DetailViewModel {
    
    func getPhotoInfo() {
        service = UnsplashService(endPoint: .random)
        
        if userPhotosCursor == nil {
            userPhotosCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
            unsplashUserPhotosdRequest = UnsplashUserPhotoRequest(with: userPhotosCursor)
        }
        
        isLoading.value = true
        
        guard let photoInfo = self.photoInfo.value else {
            return
        }
        
        service.getPhotoInfo(id: photoInfo.id, pageRequest: unsplashUserPhotosdRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                    
                    self.photoRespone.value = respone
                    
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print("statusCodeError \(code)")
                        default:
                            self.error.value = error
                    }
            }
        }
    }
    
    
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
