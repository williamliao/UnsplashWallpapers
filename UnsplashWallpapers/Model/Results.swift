//
//  Results.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Results: Codable, Identifiable {
    let id: String
    let created_at: String
    let updated_at: String
    let width: Int
    let height: Int
    let color: String
    let description: String?
    let alt_description: String?
    let urls: Urls
    let links: Links
    let categories: Categories?
    let likes: Int
    let liked_by_user: Bool
    let current_user_collections: Current_user_collections?
    let user: User
    let tags: [Tags]
}
