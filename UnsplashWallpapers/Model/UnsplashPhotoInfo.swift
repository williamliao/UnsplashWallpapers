//
//  UnsplashPhotoInfo.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/29.
//

import Foundation

struct UnsplashPhotoInfo:Codable {
    let id:String
    let created_at: String?
    let updated_at: String?
    let width: Int
    let height: Int
    let color: String
    let blur_hash: String?
    let likes: Int?
    let liked_by_user: Bool
    let downloads: Int?
    let description: String?
    let exif: Exif?
    let location: Location?
    let tags: [Tags]?
    let current_user_collections: [Current_user_collections]?
    let urls: Urls
    let links: Links
    let user: User
}

extension UnsplashPhotoInfo: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: UnsplashPhotoInfo, rhs: UnsplashPhotoInfo) -> Bool {
        return lhs.id == rhs.id
    }
}
