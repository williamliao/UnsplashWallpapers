//
//  PhotoInfo.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/27.
//

import Foundation

class PhotoInfo:Codable {
    let id: String
    let title:String
    let url: Urls
    let profile_image: Profile_image
    
    init(id: String, title:String, url:Urls, profile_image:Profile_image) {
        self.id = id
        self.title = title
        self.url = url
        self.profile_image = profile_image
    }
}

extension PhotoInfo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension PhotoInfo: Equatable {
    static func == (lhs: PhotoInfo, rhs: PhotoInfo) -> Bool {
        return lhs.title == rhs.title && lhs.id == rhs.id && lhs.url == rhs.url && lhs.profile_image == rhs.profile_image
    }
}
