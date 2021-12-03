//
//  UserProfileHeaderView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import UIKit

class UserProfileHeaderView: UIView {
    var titleLabel: UILabel!
    var avatarImageView: UIImageView!
    
    private var animator: UIViewPropertyAnimator?
    
    var imageCombineDownloader = ImageCombineDownloader()

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

extension UserProfileHeaderView {
    func configureView() {
        
        //self.backgroundColor = .systemBackground
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
     
        avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.borderColor = traitCollection.userInterfaceStyle == .light ? UIColor.black.cgColor : UIColor.white.cgColor
        avatarImageView.clipsToBounds = true
        avatarImageView.accessibilityIgnoresInvertColors = true
        
        self.addSubview(avatarImageView)
        self.addSubview(titleLabel)
    }
    
    func configureConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
     
        NSLayoutConstraint.activate([
            
            avatarImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            avatarImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalToConstant: 48),
         
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            titleLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 5),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),
        ])
    }
}

// MARK:- private
extension UserProfileHeaderView {
    
    func configureImage(with url: URL) {
        imageCombineDownloader.download(url: url) { [weak self] (image) in
            self?.showImage(image: image)
        }
    }
    
    private func showImage(image: UIImage?) {
        DispatchQueue.main.async {
            self.avatarImageView.alpha = 0.0

            guard let image = image else {
                return
            }

            self.avatarImageView.image = image
            self.avatarImageView.layer.cornerRadius = image.size.height/2
            
            self.animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: [.curveEaseOut, .transitionCrossDissolve], animations: {
                self.avatarImageView.alpha = 1.0
            })
        }
    }
}
