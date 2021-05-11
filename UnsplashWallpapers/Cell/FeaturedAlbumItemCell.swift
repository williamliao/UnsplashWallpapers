//
//  FeaturedAlbumItemCell.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import UIKit

class FeaturedAlbumItemCell: UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: FeaturedAlbumItemCell.self)
    }
    
    let titleLabel = UILabel()
    let imageCountLabel = UILabel()
    let featuredPhotoView = UIImageView()
    let contentContainer = UIView()
    
    private var act = UIActivityIndicatorView(style: .large)
    private let downloader = ImageCombineDownloader()

    var title: String? {
      didSet {
        configure()
      }
    }

    var totalNumberOfImages: Int? {
      didSet {
        configure()
      }
    }

    var featuredPhotoURL: URL? {
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

extension FeaturedAlbumItemCell {
  func configure() {
    contentContainer.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(featuredPhotoView)
    contentView.addSubview(contentContainer)

    featuredPhotoView.translatesAutoresizingMaskIntoConstraints = false
    if let featuredPhotoURL = featuredPhotoURL {
    
        if isLandscape {
            self.configureImage(with: featuredPhotoURL)
        } else {
            let adjustString = featuredPhotoURL.absoluteString.replacingOccurrences(of: "fit=max", with: "&ar=16:9&fit=crop")
            
            guard let url = URL(string: adjustString) else {
                return
            }
            
            self.configureImage(with: url)
        }
    }
    featuredPhotoView.layer.cornerRadius = 4
    featuredPhotoView.clipsToBounds = true
    //featuredPhotoView.contentMode = .scaleAspectFit
    contentContainer.addSubview(featuredPhotoView)

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = title
    titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    titleLabel.adjustsFontForContentSizeCategory = true
    contentContainer.addSubview(titleLabel)

    imageCountLabel.translatesAutoresizingMaskIntoConstraints = false
    if let totalNumberOfImages = totalNumberOfImages {
      imageCountLabel.text = "\(totalNumberOfImages) photos"
    }
    imageCountLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    imageCountLabel.adjustsFontForContentSizeCategory = true
    imageCountLabel.textColor = .placeholderText
    contentContainer.addSubview(imageCountLabel)
    
    act.color = traitCollection.userInterfaceStyle == .light ? UIColor.white : UIColor.black
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

      imageCountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
      imageCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      imageCountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        
        act.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        act.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }
}

extension FeaturedAlbumItemCell {
    
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

            self.featuredPhotoView.image = image
            
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
        featuredPhotoURL = nil
        featuredPhotoView.image = nil
        downloader.cancel()
    }
}
