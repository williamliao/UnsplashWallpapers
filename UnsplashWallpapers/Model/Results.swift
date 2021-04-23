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
    let categories: [Categories]?
    let likes: Int
    let liked_by_user: Bool
    let current_user_collections: Current_user_collections?
    let user: User
    let tags: [Tags]
    let blur_hash: String
    let promoted_at: String?
    let sponsorship: Sponsorship?
}

struct Sponsorship: Codable {
    let tagline_url: String?
    let sponsor: Sponsor?
    let impression_urls: [URL]?
    let tagline: String?
}

struct Sponsor: Codable {
    let id: String
    let total_photos: NSInteger
    let for_hire: Bool
    let twitter_username: String?
    let instagram_username: String?
    let portfolio_url: String
    let bio: String?
    let accepted_tos: Bool
    let location: String
    let first_name: String?
    let updated_at: String
    let username: String
    let link: Links
    let profile_image: Profile_image
    let last_name: String?
    let name: String?
    let total_likes: NSInteger
    let total_collections: NSInteger
}

extension Sponsor: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Sponsor, rhs: Sponsor) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Results: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Results, rhs: Results) -> Bool {
        return lhs.id == rhs.id
    }
}
