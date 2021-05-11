//
//  DetailView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/22.
//

import UIKit

class DetailView: UIView {
    let viewModel: DetailViewModel
    
    let photoExifViewModel = PhotoExifViewModel()
    
    var coordinator: MainCoordinator?
    
    init(viewModel: DetailViewModel, coordinator: MainCoordinator?) {
        self.viewModel = viewModel
        self.coordinator = viewModel.coordinator
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageView: UIImageView!
    var scrollView: UIScrollView!
    let downloadButton = UIButton(type: .custom)
    let infoButton = UIButton(type: .custom)
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
        
        createDownloadButton()
        createInfoButton()
        configureConstraints()
    }
    
    func createDownloadButton() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 64, weight: .bold, scale: .large)
        let tintColor = self.traitCollection.userInterfaceStyle == .light ? UIColor.black : UIColor.white
        let image = UIImage(systemName: "arrow.down.circle", withConfiguration: largeConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
        downloadButton.setImage(image, for: .normal)
        downloadButton.addTarget(self, action: #selector(downloadButtonTouch), for: .touchUpInside)
        
        scrollView.addSubview(downloadButton)
    }
    
    func createInfoButton() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 64, weight: .bold, scale: .large)
        let tintColor = self.traitCollection.userInterfaceStyle == .light ? UIColor.black : UIColor.white
        let image = UIImage(systemName: "info.circle.fill", withConfiguration: largeConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
        infoButton.setImage(image, for: .normal)
        infoButton.addTarget(self, action: #selector(infoButtonTouch), for: .touchUpInside)
        scrollView.addSubview(infoButton)
    }
    
    func configureConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        act.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            
            downloadButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            downloadButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            downloadButton.widthAnchor.constraint(equalToConstant: 44),
            downloadButton.heightAnchor.constraint(equalToConstant: 44),
            
            infoButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            infoButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
            infoButton.widthAnchor.constraint(equalToConstant: 44),
            infoButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    func configureView(photo: PhotoInfo) {
        
        guard let url = URL(string: photo.url.regular) else {
            return
        }
       
        viewModel.isLoading.value = true
        viewModel.downloader.downloadWithErrorHandler(url: url) { [weak self] (image, error) in
            self?.viewModel.isLoading.value = false
            guard error == nil else {
                return
            }
            self?.showImage(image: image)
        }
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
    }
    
    private func showImage(image: UIImage?) {
        
        guard let image = image else {
            return
        }
        
        //let imageAspectRatio = image.size.width / image.size.height

        //imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: imageAspectRatio).isActive = true
        
        DispatchQueue.main.async {
            
            self.imageView.image = image
        
            self.updateMinZoomScaleForSize(self.imageView.bounds.size)

            self.scrollView.contentSize = self.imageView.bounds.size
            
        }
    }
}

//MARK:- Info
extension DetailView {
    @objc func infoButtonTouch() {
        viewModel.getPhotoInfo()
    }
    
    func getPhotoInfo() {
        guard let photoInfo = self.viewModel.photoRespone.value else {
            return
        }
        

        photoExifViewModel.userInterfaceStyle = self.traitCollection.userInterfaceStyle
        photoExifViewModel.photoInfo = photoInfo
        
        let vc = PhotoExifViewController()
        vc.viewModel = photoExifViewModel
        //vc.photoInfo = photoInfo
        
        self.viewModel.photoRespone.value = nil
        
        coordinator?.presentExifView(vc: vc)
    }
}

//MARK:- Downloading
extension DetailView {
    @objc func downloadButtonTouch() {

        guard let urlString = viewModel.photoInfo.value?.url.full else {
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        downloadImage(from: url)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                
                if let image = UIImage(data: data) {
                    self?.writeToPhotoAlbum(image: image)
                }
            }
        }
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        // save complete
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
    }
    
    func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset

        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset

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
