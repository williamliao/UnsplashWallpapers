//
//  SharedAlbumItemCell.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import UIKit
import Combine

class SharedAlbumItemCell: UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: SharedAlbumItemCell.self)
    }
    
    let titleLabel = UILabel()
    let ownerLabel = UILabel()
    let featuredPhotoView = UIImageView()
    let ownerAvatar = UIImageView()
    let contentContainer = UIView()
    
    private var cancellable: AnyCancellable?
    private var act = UIActivityIndicatorView(style: .large)
    
    var title: String? {
      didSet {
        configure()
      }
    }

    var featuredPhotoURL: URL? {
      didSet {
        configure()
      }
    }

    override init(frame: CGRect) {
      super.init(frame: frame)
      configure()
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
}

extension SharedAlbumItemCell {
  func configure() {
    contentContainer.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(featuredPhotoView)
    contentView.addSubview(contentContainer)

    featuredPhotoView.translatesAutoresizingMaskIntoConstraints = false
    if let featuredPhotoURL = featuredPhotoURL {
      //featuredPhotoView.image = UIImage(contentsOfFile: featuredPhotoURL.path)
        self.configureImage(with: featuredPhotoURL)
        
    }
    featuredPhotoView.layer.cornerRadius = 4
    featuredPhotoView.clipsToBounds = true
    contentContainer.addSubview(featuredPhotoView)

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    //titleLabel.text = title
    titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    titleLabel.adjustsFontForContentSizeCategory = true
    contentContainer.addSubview(titleLabel)

    ownerLabel.translatesAutoresizingMaskIntoConstraints = false
    //ownerLabel.text = "From \(owner.name())"
    ownerLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    ownerLabel.adjustsFontForContentSizeCategory = true
    ownerLabel.textColor = .placeholderText
    contentContainer.addSubview(ownerLabel)

    ownerAvatar.translatesAutoresizingMaskIntoConstraints = false
    //ownerAvatar.image = owner.avatar()
    ownerAvatar.layer.cornerRadius = 15
    ownerAvatar.layer.borderColor = UIColor.systemBackground.cgColor
    ownerAvatar.layer.borderWidth = 1
    ownerAvatar.clipsToBounds = true
    contentContainer.addSubview(ownerAvatar)
    
    act.color = traitCollection.userInterfaceStyle == .light ? UIColor.black : UIColor.white
    act.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(act)

    let spacing = CGFloat(10)
    NSLayoutConstraint.activate([
      contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
      contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

      featuredPhotoView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
      featuredPhotoView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
      featuredPhotoView.topAnchor.constraint(equalTo: contentContainer.topAnchor),

      titleLabel.topAnchor.constraint(equalTo: featuredPhotoView.bottomAnchor, constant: spacing),
      titleLabel.leadingAnchor.constraint(equalTo: featuredPhotoView.leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: featuredPhotoView.trailingAnchor),

      ownerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
      ownerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      ownerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      ownerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

      ownerAvatar.heightAnchor.constraint(equalToConstant: 30),
      ownerAvatar.widthAnchor.constraint(equalToConstant: 30),
      ownerAvatar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -spacing),
      ownerAvatar.bottomAnchor.constraint(equalTo: featuredPhotoView.bottomAnchor, constant: -spacing),
        
        act.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        act.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
    ])
  }
}

extension SharedAlbumItemCell {
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

            let resizeImage = self.resizedImage(at: image, for: CGSize(width: UIScreen.main.bounds.size.width, height: image.size.height))
            self.featuredPhotoView.image = resizeImage
            
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
        featuredPhotoView.image = nil
        cancellable?.cancel()
    }
}