//
//  FavoriteManager.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/22.
//

import Foundation

typealias CompletionHandler = (_ success:Bool) -> Void

class FavoriteManager {
    static let sharedInstance = FavoriteSingleton()
}

class FavoriteSingleton {
    static let sharedInstance: FavoriteSingleton = {
        let instance = FavoriteSingleton()
        // setup code
        return instance
    }()
    
    var favorites: Observable<Set<Response>> = Observable(Set<Response>())
}

extension FavoriteSingleton {
    
    func handleSaveAction(photo: Response, isFavorite: Bool) {
        if isFavorite {
            self.favorites.value.insert(photo)
        } else {
            self.favorites.value.remove(photo)
        }
        
        saveToFavorite()
    }
    
    func saveToFavorite() {
        do {
            try UserDefaults.standard.setObject(self.favorites.value, forKey: "favorites")
            UserDefaults.standard.synchronize()
        } catch  {
            print("saveToFavorite \(error)")
        }
    }
    
    func loadFavorite(key: String, completionHandler: CompletionHandler) {
        let userDefaults = UserDefaults.standard
        if UserDefaults.standard.object(forKey: key) != nil {
            do {
                self.favorites.value = try userDefaults.getObject(forKey: key, castTo: Set<Response>.self)
                completionHandler(true)
            } catch  {
                print("loadFavorite \(error)")
                completionHandler(false)
            }
        }
    }
}
