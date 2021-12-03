//
//  AlbumPhotoItemCell.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import UIKit

class AlbumPhotoItemCell: UICollectionViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: AlbumPhotoItemCell.self)
    }
    
    let imageView = UIImageView()
    let contentContainer = UIView()
    
    private let downloader = ImageCombineDownloader()
    private var act = UIActivityIndicatorView(style: .large)

    var photoURL: URL? {
        didSet {
            configure()
        }
    }
    
    var isLandscape = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AlbumPhotoItemCell {
    func configure() {
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentContainer)

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.accessibilityIgnoresInvertColors = true

        guard let photoURL = self.photoURL else { return }
        self.configureImage(with: photoURL)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(imageView)
        
        act.color = traitCollection.userInterfaceStyle == .light ? UIColor.white : UIColor.black
        act.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(act)

        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            imageView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            
            act.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            act.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}

extension AlbumPhotoItemCell {
    func configureImage(with url: URL) {
        isLoading(isLoading: true)
        
        downloader.download(url: url) { [weak self] (image) in
            self?.showImage(image: image)
            self?.isLoading(isLoading: false)
        }
    }
    
    private func showImage(image: UIImage?) {
        DispatchQueue.main.async {
           
            guard let image = image else {
                return
            }
            self.imageView.image = image
            
        }
    }
 
    func isLoading(isLoading: Bool) {
        if isLoading {
            act.startAnimating()
        } else {
            act.stopAnimating()
        }
        act.isHidden = !isLoading
    }
 
    override func prepareForReuse() {
        super.prepareForReuse()
        photoURL = nil
        imageView.image = nil
        downloader.cancel()
    }
}
