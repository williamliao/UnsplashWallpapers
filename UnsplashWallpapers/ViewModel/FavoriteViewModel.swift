//
//  FavoriteViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/22.
//

import UIKit

class FavoriteViewModel {
    var coordinator: MainCoordinator?
    var respone: Observable<[Response]?> = Observable([])
    var error: Observable<Error?> = Observable(nil)
    
    let favoriteManager = FavoriteManager.sharedInstance
}

extension FavoriteViewModel {
    func loadFavorite() {
        
        favoriteManager.loadFavorite(key: "favorites") {(success) in
            if (success) {
                //print(favoriteManager.favorites.value)
                respone.value = Array(favoriteManager.favorites.value)
            } else {
                
            }
        }
    }
}
