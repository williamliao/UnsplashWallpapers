//
//  PhotoListViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

class PhotoListViewModel  {
    var coordinator: MainCoordinator?
    var respone: Observable<[Response]?> = Observable([])
}
