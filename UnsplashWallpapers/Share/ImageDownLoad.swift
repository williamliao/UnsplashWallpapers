//
//  ImageDownLoad.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import UIKit

@available(iOS 15.0.0, *)
actor ImageDownloader {
    
    enum ImageDownloadError: Error {
        case badImage
        case invalidMetadata
    }

    private var cache: [URL: UIImage] = [:]

    func image(from url: URL) async throws -> UIImage? {
        if let cached = cache[url] {
            return cached
        }

        let image = try await downloadImage(imageUrl: url)

        cache[url] = cache[url, default: image]

        return image
    }

    private func downloadImage(imageUrl: URL) async throws -> UIImage {
        let imageRequest = URLRequest(url: imageUrl)
        let (data, imageResponse) = try await URLSession.shared.data(for: imageRequest)
        guard let image = UIImage(data: data), (imageResponse as? HTTPURLResponse)?.statusCode == 200 else {
            throw ImageDownloadError.badImage
        }
        return image
    }
}
