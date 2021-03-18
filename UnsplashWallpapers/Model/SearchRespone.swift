//
//  SearchRespone.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct SearchRespone: Codable {
    var total: NSInteger
    var total_pages: NSInteger
    var results: [Results]
}
