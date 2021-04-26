//
//  Response.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct Response: Codable, Identifiable {
    let sponsorship: String?
    let id: String
    let created_at: String?
    let updated_at: String?
    let width: Int
    let height: Int
    let color: String
    let description: String?
    let alt_description: String?
    let urls: Urls
    let links: Links
    let categories: [Categories]?
    let likes: Int?
    let liked_by_user: Bool
    let current_user_collections: [Current_user_collections]?
    let user: User?
    let exif: Exif?
    let location: Location?
    let views: Int
    let downloads: Int
    let promoted_at: String?
    let blur_hash: String?
    let viewsCount: Int?
}

extension Response: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(created_at)
        hasher.combine(updated_at)
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(color)
        hasher.combine(description)
        hasher.combine(alt_description)
        hasher.combine(urls)
        hasher.combine(links)
        hasher.combine(categories)
        hasher.combine(likes)
        hasher.combine(liked_by_user)
        hasher.combine(user)
        hasher.combine(exif)
        hasher.combine(location)
        hasher.combine(views)
        hasher.combine(downloads)
        hasher.combine(promoted_at)
        hasher.combine(blur_hash)
        hasher.combine(viewsCount)
    }
}

extension Response: Equatable {
    static func == (lhs: Response, rhs: Response) -> Bool {
        return lhs.id == rhs.id
    }
}
