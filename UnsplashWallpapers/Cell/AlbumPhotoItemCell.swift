//
//  AlbumPhotoItemCell.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import UIKit
import Combine

class AlbumPhotoItemCell: UICollectionViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: AlbumPhotoItemCell.self)
    }
    
    let imageView = UIImageView()
    let contentContainer = UIView()
    
    private var cancellable: AnyCancellable?
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
        
      //  imageView.contentMode = .scaleAspectFit

      guard let photoURL = self.photoURL else { return }
       // self.configureImage(with: photoURL)
        let adjustString = photoURL.absoluteString.replacingOccurrences(of: "fit=max", with: "&ar=16:9&fit=crop")
        
        guard let url = URL(string: adjustString) else {
            return
        }
        self.configureImage(with: url)
    

      imageView.translatesAutoresizingMaskIntoConstraints = false
      contentContainer.addSubview(imageView)

      NSLayoutConstraint.activate([
        contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
        contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

        imageView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
        imageView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
        imageView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
        imageView.topAnchor.constraint(equalTo: contentContainer.topAnchor)
      ])
    }
}

extension AlbumPhotoItemCell {
    func configureImage(with url: URL) {
        isLoading(isLoading: true)
        cancellable = self.loadImage(for: url).sink { [weak self] image in
            self?.showImage(image: image)
            self?.isLoading(isLoading: false)
        }
    }
    
    private func showImage(image: UIImage?) {
        DispatchQueue.main.async {
           
            guard let image = image else {
                return
            }
           
            //let resizeImage = self.resizedImage(at: image, for: CGSize(width: UIScreen.main.bounds.size.width, height: image.size.height))
            self.imageView.image = image
            
        }
    }
    
    func resizedImage(at image: UIImage, for size: CGSize) -> UIImage? {
       
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: size))
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
    
    private func loadImage(for url: URL) -> AnyPublisher<UIImage?, Never> {
        return Just(url)
        .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
            return ImageLoader.shared.loadImage(from: url)
        })
        .eraseToAnyPublisher()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoURL = nil
        imageView.image = nil
        cancellable?.cancel()
    }
}
