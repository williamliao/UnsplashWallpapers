//
//  ImageLoadOperation.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/5.
//

import UIKit

class ImageLoadOperation: Operation {
    private var imgUrl: URL
    private let downloader = ImageCombineDownloader()
    var completionHandler: ((UIImage?) -> Void)?
    var image: UIImage?
    
    init(imgUrl: URL) {
        self.imgUrl = imgUrl
    }
        
    override func cancel() {
        downloader.cancel()
        super.cancel()
    }
    
    override func main() {
        if isCancelled {
            return
        }

        downloader.download(url: self.imgUrl) { [weak self] (downloadImage) in
            guard let strongSelf = self else { return }
            strongSelf.image = downloadImage
            strongSelf.completionHandler?(downloadImage)
        }
    }
}
