//
//  UnsplashAlbumsRequest.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import Foundation

class UnsplashAlbumsRequest {
    
    let cursor: Cursor

    init(with cursor: Cursor) {
        self.cursor = cursor
    }

    convenience init(with page: Int = 1, perPage: Int = 10) {
        self.init(with: Cursor(query: "", page: page, perPage: perPage, parameters: nil))
    }

    func nextCursor() -> Cursor {
        return Cursor(query: cursor.query, page: cursor.page + 1, perPage: cursor.perPage, parameters: cursor.parameters)
    }
}
