//
//  DetailView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/22.
//

import UIKit

class DetailView: UIView {
    let viewModel: DetailViewModel
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageView: UIImageView!
    private var act = UIActivityIndicatorView(style: .large)
}

extension DetailView {
    func createView() {
        //rootView.backgroundColor = .systemBackground
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        self.addSubview(act)
        
        configureConstraints()
    }
    
    func configureConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        act.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            act.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 10),
            act.centerXAnchor.constraint(equalTo: self.centerXAnchor),
         
        ])
    }
    
    func configureView(photo: Response) {
        
        guard let url = URL(string: photo.urls.full) else {
            return
        }
        
        viewModel.configureImage(with: url)
    }
    
    func observerBindData() {
    
        viewModel.isLoading.bind { [weak self] (isLoading) in
            
            if isLoading {
                self?.act.startAnimating()
            } else {
                self?.act.stopAnimating()
            }
            self?.act.isHidden = !isLoading
        }
        
        viewModel.respone.bind { [weak self] (respone) in
            guard let res = respone else {
                return
            }
            self?.configureView(photo: res)
        }
        
        viewModel.restultImage.bind { (image) in
            
            print(image)
            
            self.showImage(image: image)
            
        }
        
    }
    
    private func showImage(image: UIImage?) {
        
        guard let image = image else {
            return
        }
        
//        let imageAspectRatio = image.size.width / image.size.height
//
//        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageAspectRatio).isActive = true
        
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
}
