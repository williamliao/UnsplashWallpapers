//
//  UsersListCollectionViewCell.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/27.
//

import UIKit
import Combine

class UsersListCollectionViewCell: UICollectionViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: UsersListCollectionViewCell.self)
    }
    
    var titleLabel: UILabel!
    var avatarImageView: UIImageView!
    
    private var cancellable: AnyCancellable?
    private var animator: UIViewPropertyAnimator?
    private var isHeightCalculated: Bool = false
    
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

extension UsersListCollectionViewCell {
    func configureView() {
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
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
    }
    
    func configureConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
     
        NSLayoutConstraint.activate([
            
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 48),
            avatarImageView.heightAnchor.constraint(equalToConstant: 48),
         
            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            //titleLabel.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: -5),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),
            
            
        ])
    }
}

// MARK:- private
extension UsersListCollectionViewCell {
    
    func configureImage(with url: URL) {
        cancellable = self.loadImage(for: url).sink { [weak self] image in
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

    private func loadImage(for url: URL) -> AnyPublisher<UIImage?, Never> {
        return Just(url)
        .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
            return ImageLoader.shared.loadImage(from: url)
        })
        .eraseToAnyPublisher()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        avatarImageView.alpha = 0.0
        animator?.stopAnimation(true)
        cancellable?.cancel()
    }
    
}
