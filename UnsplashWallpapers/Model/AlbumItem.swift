//
//  AlbumItem.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import Foundation

class AlbumItem: Codable, Hashable {
    var identifier = UUID()
    let albumURL: URL
    let albumTitle: String
    let imageItems: [AlbumDetailItem]

    init(albumTitle: String, albumURL: URL, imageItems: [AlbumDetailItem] = []) {
        self.albumURL = albumURL
        self.albumTitle = albumTitle
        self.imageItems = imageItems
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: AlbumItem, rhs: AlbumItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

class AlbumDetailItem:Codable, Hashable {
    var identifier = UUID()
    let photoURL: URL
    let thumbnailURL: URL
    let subitems: [AlbumDetailItem]

    init(photoURL: URL, thumbnailURL: URL, subitems: [AlbumDetailItem] = []) {
      self.photoURL = photoURL
      self.thumbnailURL = thumbnailURL
      self.subitems = subitems
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: AlbumDetailItem, rhs: AlbumDetailItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
