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
    var photoInfo: Observable<[PhotoInfo]?> = Observable([])
    var error: Observable<Error?> = Observable(nil)
    
    let favoriteManager = FavoriteManager.sharedInstance
}

extension FavoriteViewModel {
    func loadFavorite() {
        
        favoriteManager.loadFavorite(key: "favorites") {(success) in
            if (success) {
                //print(favoriteManager.favorites.value)
                photoInfo.value = Array(favoriteManager.favorites.value)
                
//                guard let combinedDict = photoInfo.value else {
//                    return
//                }
//
//                for info in photoInfoArray {
//                   // photoInfo.value.forEach { (k,v) in info[k] = v }
//                    photoInfo.value = combinedDict.merging(info) { $1 }
//                }
                
            } else {
                
            }
        }
    }
}
