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
    var scrollView: UIScrollView!
    private var act = UIActivityIndicatorView(style: .large)
    
    var imageViewBottomConstraint: NSLayoutConstraint!
    var imageViewLeadingConstraint: NSLayoutConstraint!
    var imageViewTopConstraint: NSLayoutConstraint!
    var imageViewTrailingConstraint: NSLayoutConstraint!
}

extension DetailView {
    func createView() {
        self.backgroundColor = .systemBackground
        
        act.color = traitCollection.userInterfaceStyle == .light ? UIColor.black : UIColor.white
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.maximumZoomScale = 4.0
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        
        scrollView.minimumZoomScale = 1.0
        scrollView.zoomScale = 1.0
        
        self.addSubview(scrollView)
        
        
        imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        scrollView.addSubview(imageView)
        scrollView.addSubview(act)
        
        configureConstraints()
    }
    
    func configureConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        act.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        imageViewLeadingConstraint = imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        imageViewTrailingConstraint = imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        imageViewTopConstraint = imageView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        imageViewBottomConstraint = imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        
        NSLayoutConstraint.activate([
            
            scrollView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: self.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            imageViewLeadingConstraint,
            imageViewTrailingConstraint,
            imageViewTopConstraint,
            imageViewBottomConstraint,

            act.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            act.centerXAnchor.constraint(equalTo: self.centerXAnchor),
         
        ])
    }

    func configureView(photo: PhotoInfo) {
        
        guard let url = URL(string: photo.url.regular) else {
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
        
        viewModel.photoInfo.bind { [weak self] (info) in
            guard let photoInfo = info else {
                return
            }
            self?.configureView(photo: photoInfo)
        }
        
        viewModel.restultImage.bind { (image) in
            
            self.showImage(image: image)
            
        }
        
    }
    
    private func showImage(image: UIImage?) {
        
        guard let image = image else {
            return
        }
        
        //let imageAspectRatio = image.size.width / image.size.height

        //imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageAspectRatio).isActive = true
        
        DispatchQueue.main.async {
            
            self.imageView.image = image
        
            //self.updateMinZoomScaleForSize(self.imageView.bounds.size)

            self.scrollView.contentSize = self.imageView.bounds.size
            
        }
    }
}

//MARK:- Sizing
extension DetailView {
    func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        
   /*     // Sizes
        let boundsSize = scrollView.bounds.size;
        let imageSize = imageView.frame.size;
        
        // Calculate Min
        let xScale = boundsSize.width / imageSize.width;
        let yScale = boundsSize.height / imageSize.height;
        let minScale = min(xScale, yScale);

        // Calculate Max
        var maxScale = 4.0;
       // if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / Double(UIScreen.main.scale);
    
            if Double(maxScale) < Double(minScale) {
                maxScale = Double(minScale * 2);
            }
    
//            if Double(minScale) >= 0.1 && Double(minScale) < 0.5 {
//                maxScale = 0.7;
//            }
//
//            if minScale >= 0.5 {
//                maxScale = max(1.0, Double(minScale));
//            }
     //   }
        
        // Apply zoom
        self.scrollView.maximumZoomScale = CGFloat(maxScale);
        self.scrollView.minimumZoomScale = minScale;
        self.scrollView.zoomScale = minScale;*/
    }
    
    func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset

        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
//        let imageViewSize = imageView.frame.size
//        let scrollViewSize = scrollView.bounds.size
//        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
//        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
//        scrollView.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)

        self.layoutIfNeeded()
    }
}

//MARK:- UIScrollViewDelegate
extension DetailView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
  
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(self.bounds.size)
    }
}
