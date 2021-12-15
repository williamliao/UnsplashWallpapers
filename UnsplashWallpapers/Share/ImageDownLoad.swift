//
//  ImageDownLoad.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import UIKit

@available(iOS 13.0.0, *)
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
//        let (data, imageResponse) = try await URLSession.shared.data(for: imageRequest)
//        guard let image = UIImage(data: data), (imageResponse as? HTTPURLResponse)?.statusCode == 200 else {
//            throw ImageDownloadError.badImage
//        }
//        return image
        
        if #available(iOS 15.0, *) {
            let (imageData, _) = try await URLSession.shared.data(for: imageRequest)
            guard let imageData = UIImage(data: imageData) else {
                throw ImageDownloadError.badImage
            }
            return imageData
        } else {
            // Fallback on earlier versions
            
            var imageData: UIImage?

            let semaphore = DispatchSemaphore(value: 0)
            let task = await URLSession.shared.dataTask(with: imageRequest, completionHandler: { data, response, error in
                
                guard let data = data, let imgData = UIImage(data: data) else {
                    return
                }
                imageData = imgData
                semaphore.signal()
            })
            task.resume()
            
            semaphore.wait()
            return imageData!
        }
        
    }
}
