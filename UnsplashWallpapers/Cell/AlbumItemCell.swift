//
//  AlbumItemCell.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import UIKit

class AlbumItemCell: UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: AlbumItemCell.self)
    }
    
    private let downloader = ImageCombineDownloader()
    private var act = UIActivityIndicatorView(style: .large)
    
    let titleLabel = UILabel()
    let featuredPhotoView = UIImageView()
    let contentContainer = UIView()
    
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

extension AlbumItemCell {
  func configure() {
    contentContainer.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(featuredPhotoView)
    contentView.addSubview(contentContainer)

    featuredPhotoView.translatesAutoresizingMaskIntoConstraints = false
    if let featuredPhotoURL = featuredPhotoURL {
        self.configureImage(with: featuredPhotoURL)
      //featuredPhotoView.image = UIImage(contentsOfFile: featuredPhotoURL.path)
    }
    featuredPhotoView.clipsToBounds = true
    contentContainer.addSubview(featuredPhotoView)

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.text = title
    titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
    titleLabel.adjustsFontForContentSizeCategory = true
    titleLabel.textColor = .white
    titleLabel.textAlignment = .center
    titleLabel.layer.shadowColor = UIColor.black.cgColor
    titleLabel.layer.shadowRadius = 3.0
    titleLabel.layer.shadowOpacity = 1.0
    titleLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
    titleLabel.layer.masksToBounds = false
    contentContainer.addSubview(titleLabel)
    
    act.color = traitCollection.userInterfaceStyle == .light ? UIColor.white : UIColor.black
    act.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(act)

    NSLayoutConstraint.activate([
        contentContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        contentContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        contentContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
        contentContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

        featuredPhotoView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
        featuredPhotoView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
        featuredPhotoView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
        featuredPhotoView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),

        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        
        act.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        act.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
    ])
  }
}

extension AlbumItemCell {
    
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
        featuredPhotoView.image = nil
        downloader.cancel()
    }
}
