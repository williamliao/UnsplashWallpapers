//
//  PhotoExifViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/29.
//

import UIKit

class PhotoExifViewController: UIViewController {
    
    var photoExifView: PhotoExifView!
    var viewModel: PhotoExifViewModel!
    var photoInfo: UnsplashPhotoInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.view.backgroundColor = .systemBackground
        
        photoExifView = PhotoExifView()
        photoExifView.photoExifViewDelegate = self

        viewModel.generateImageFromMap { [weak self] (image) in
            self?.photoExifView.mapImageView.image = image
        }
        
        viewModel.setupInfo { [weak self] (dict) in
            
            if let location = dict["location"] as? NSMutableAttributedString {
                self?.photoExifView.locationLabel.attributedText = location
            }
            
            if let description = dict["description"] as? String {
                self?.photoExifView.descriptionLabel.text = description
            }
            
            if let descriptionHeight = dict["descriptionHeight"] as? CGFloat {
                self?.photoExifView.descriptionConstraint.constant = descriptionHeight
            }
            
            if let dimension = dict["dimension"] as? String {
                self?.photoExifView.dimensionLabel.text = dimension
            }
            
            if let published = dict["published"] as? String {
                self?.photoExifView.publishedLabel.text = published
            }
            
            if let focal = dict["focal"] as? String {
                self?.photoExifView.focalLabel.text = focal
            }
            
            if let make = dict["make"] as? String {
                self?.photoExifView.makeLabel.text = make
            }
            
            if let model = dict["model"] as? String {
                self?.photoExifView.modelLabel.text = model
            }
            
            if let iso = dict["iso"] as? String {
                self?.photoExifView.isoLabel.text = iso
            }
            
            if let aperture = dict["aperture"] as? String {
                self?.photoExifView.apertureLabel.text = aperture
            }
            
        }
 
        photoExifView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(photoExifView)
        
        NSLayoutConstraint.activate([
            photoExifView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            photoExifView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            photoExifView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            photoExifView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PhotoExifViewController: PhotoExifViewDelegate {
    func userDidTouchCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
