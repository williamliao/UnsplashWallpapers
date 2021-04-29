//
//  PhotoInfo.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/27.
//

import Foundation

struct PhotoInfo:Codable {
    let id: String
    let title:String
    let url: Urls
    let profile_image: Profile_image
}

extension PhotoInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(id)
    }
}

extension PhotoInfo: Equatable {
    static func == (lhs: PhotoInfo, rhs: PhotoInfo) -> Bool {
        return lhs.title == rhs.title && lhs.id == rhs.id
    }
}
