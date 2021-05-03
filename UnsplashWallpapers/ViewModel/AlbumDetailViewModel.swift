//
//  AlbumDetailViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import Foundation

class AlbumDetailViewModel {
    var coordinator: MainCoordinator?
    
    var detailRespone: Observable<[AlbumDetailItem]> = Observable([])
}
