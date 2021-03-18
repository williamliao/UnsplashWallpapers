//
//  Source.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Source: Codable {
    let ancestry: Ancestry
    let title: String
    let description: String?
    let meta_title: String
    let meta_description: String
    let cover_photo: Cover_photo
}
