//
//  PhotoListCollectionViewCell.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import UIKit

class PhotoListCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier: String {
        return String(describing: PhotoListCollectionViewCell.self)
    }
    
    var titleLabel: UILabel!
    var thumbnailImageView: UIImageView!
    let effect = UIBlurEffect(style: .dark)
    var blurEffectView : UIVisualEffectView!
    
    private let downloader = ImageCombineDownloader()
    private var act = UIActivityIndicatorView(style: .large)

    var isHeightCalculated: Bool = false
    
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
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        blurEffectView = UIVisualEffectView(effect: effect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
     
        thumbnailImageView = UIImageView()
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.accessibilityIgnoresInvertColors = true
        
        act.color = traitCollection.userInterfaceStyle == .light ? UIColor.black : UIColor.white

        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.addSubview(blurEffectView)
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
            
            blurEffectView.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: 5),
            blurEffectView.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: -5),
            blurEffectView.heightAnchor.constraint(equalToConstant: 16),

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
        
        DispatchQueue.global().async { [weak self] in
          
            self?.downloader.downloadWithErrorHandler(url: url, completionHandler: { [weak self] (image, error) in
                
                DispatchQueue.main.async {
                    self?.isLoading(isLoading: false)
                }
                
                guard error == nil else {
                    
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                guard let image = image else {
                    
                    return
                }
                self?.showImage(image: image)
                
            })
        }
    }
    
    func showImage(image: UIImage?) {
        DispatchQueue.main.async {
           
            guard let image = image else {
                return
            }
            
            //let resizeImage = self.resizedImage(at: image, for: CGSize(width: UIScreen.main.bounds.size.width, height: image.size.height))
            self.thumbnailImageView.image = image
        }
    }
    
    func resizedImage(at image: UIImage, for size: CGSize) -> UIImage? {
        
        if #available(iOS 15.0, *) {
            let thumbnailImg = image
            return thumbnailImg.preparingThumbnail(of: size)
        } else {
            // Fallback on earlier versions
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { (context) in
                image.draw(in: CGRect(origin: .zero, size: size))
            }
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
        downloader.cancel()
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        //Exhibit A - We need to cache our calculation to prevent a crash.
        if !isHeightCalculated {
            setNeedsLayout()
            layoutIfNeeded()
            let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
            var newFrame = layoutAttributes.frame
            newFrame.size.width = CGFloat(ceilf(Float(size.width)))
            newFrame.size.height = CGFloat(ceilf(Float(size.height)))
            layoutAttributes.frame = newFrame
            isHeightCalculated = true
        }
        return layoutAttributes
    }
}


