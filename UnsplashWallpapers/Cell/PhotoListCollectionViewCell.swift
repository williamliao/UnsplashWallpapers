//
//  PhotoListCollectionViewCell.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import UIKit
import Combine

class PhotoListCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: PhotoListCollectionViewCell.self)
    }
    
    var titleLabel: UILabel!
    var thumbnailImageView: UIImageView!
    
    private var cancellable: AnyCancellable?
    private var animator: UIViewPropertyAnimator?
    private var act = UIActivityIndicatorView(style: .large)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
        configureConstraints()
    }
}
// MARK:- View
extension PhotoListCollectionViewCell {
    
    func configureView() {
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
     
        thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.clipsToBounds = true
        
        act.color = .systemBackground
    
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(act)
        thumbnailImageView.addSubview(titleLabel)
    }
    
    func configureConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        act.translatesAutoresizingMaskIntoConstraints = false
     
        NSLayoutConstraint.activate([
            
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
         
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 5),
            titleLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -5),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),
            
            act.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            act.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
        ])
    }
}

// MARK:- private
extension PhotoListCollectionViewCell {
    
    func configureImage(with url: URL) {
        isLoading(isLoading: true)
        cancellable = self.loadImage(for: url).sink { [weak self] image in
            self?.showImage(image: image)
            self?.isLoading(isLoading: false)
        }
    }
    
    private func showImage(image: UIImage?) {
        DispatchQueue.main.async {
            self.thumbnailImageView.alpha = 0.0
           // self.thumbnailImageView.image = image
            
//            if let width = image?.size.width, let height = image?.size.height {
//                let at = width / height
//                self.thumbnailImageView.widthAnchor.constraint(equalTo: self.thumbnailImageView.heightAnchor, multiplier: at).isActive = true
//            } else {
//                return
//            }
            
            guard let image = image else {
                return
            }
            
//            if image.size.height > image.size.width {
//                self.thumbnailImageView.image = image
//            } else {
//                let resizeImage = self.resizedImage(at: image, for: CGSize(width: UIScreen.main.bounds.size.width, height: 300))
//                self.thumbnailImageView.image = resizeImage
//            }
            
            let resizeImage = self.resizedImage(at: image, for: CGSize(width: UIScreen.main.bounds.size.width, height: 300))
            self.thumbnailImageView.image = resizeImage
            
            self.animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveEaseOut, .transitionCrossDissolve], animations: {
                self.thumbnailImageView.alpha = 1.0
            })
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
        thumbnailImageView.image = nil
        thumbnailImageView.alpha = 0.0
        animator?.stopAnimation(true)
        cancellable?.cancel()
    }
    
}


