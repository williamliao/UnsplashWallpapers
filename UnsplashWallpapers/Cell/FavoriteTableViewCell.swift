//
//  FavoriteTableViewCell.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/22.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    static var reuseIdentifier: String {
        return String(describing: FavoriteTableViewCell.self)
    }
    
    var titleLabel: UILabel!
    var thumbnailImageView: UIImageView!
    var avatarImageView: UIImageView!
    
    private let downloader = ImageCombineDownloader()
    private let downloader2 = ImageCombineDownloader()
    private var animator: UIViewPropertyAnimator?
    private var act = UIActivityIndicatorView(style: .large)
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension FavoriteTableViewCell {
    func configureView() {
        
        self.backgroundColor = .systemBackground
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
     
        thumbnailImageView = UIImageView()
        thumbnailImageView.clipsToBounds = true
        
        avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.borderColor = traitCollection.userInterfaceStyle == .light ? UIColor.black.cgColor : UIColor.white.cgColor
        avatarImageView.clipsToBounds = true
        
        act.color = .systemBackground
    
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(act)
        contentView.addSubview(avatarImageView)
        thumbnailImageView.addSubview(titleLabel)
    }
    
    func configureConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        act.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
     
        NSLayoutConstraint.activate([
            
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalToConstant: 48),
            
            thumbnailImageView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
         
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 15),
            titleLabel.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -15),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),
            
            act.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            act.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
        ])
    }
}

// MARK:- private
extension FavoriteTableViewCell {
    
    func configureImage(with url: URL) {
        isLoading(isLoading: true)
        
        downloader.download(url: url) { [weak self] (image) in
            self?.showImage(image: image)
            self?.isLoading(isLoading: false)
        }
    }
    
    func configureAImage(with url: URL) {
        downloader2.download(url: url) { [weak self] (image) in
            self?.showImage2(image: image)
        }
    }
    
    private func showImage(image: UIImage?) {
        DispatchQueue.main.async {

            guard let image = image else {
                return
            }
            
            self.thumbnailImageView.image = image
        }
    }
    
    private func showImage2(image: UIImage?) {
        DispatchQueue.main.async {
    
            guard let image = image else {
                return
            }

            self.avatarImageView.image = image
            self.avatarImageView.layer.cornerRadius = image.size.height/2
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        avatarImageView.image = nil
        downloader.cancel()
        downloader2.cancel()
    }
}
