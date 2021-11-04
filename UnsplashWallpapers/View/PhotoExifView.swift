//
//  PhotoExifView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/29.
//

import UIKit
import MapKit

protocol PhotoExifViewDelegate: AnyObject {
    func userDidTouchCloseButton()
}

class PhotoExifView: UIView {
    let closeButton = UIButton(type: .custom)
    
    weak var photoExifViewDelegate: PhotoExifViewDelegate!
    
    let mapImageView = UIImageView()
    
    let titleLabel = UILabel()
    let locationLabel = UILabel()
    let descriptionLabel = UILabel()
    
    var descriptionConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    let makeLabel = UILabel()
    let focalLabel = UILabel()
    let modelLabel = UILabel()
    let isoLabel = UILabel()
    let shutterLabel = UILabel()
    let dimensionLabel = UILabel()
    let apertureLabel = UILabel()
    let publishedLabel = UILabel()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
}

// MARK:- View
extension PhotoExifView {
    func configureView() {
        let theme = ThemeManager.currentTheme()
        self.backgroundColor = theme.backgroundColor
       
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .left
        titleLabel.text = "Info"
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 18)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byCharWrapping;
        descriptionLabel.textAlignment = .left
       
        locationLabel.font = UIFont.systemFont(ofSize: 18)
        locationLabel.textColor = .label
        locationLabel.textAlignment = .left
        
        closeButton.addTarget(self, action: #selector(closeButtonTouch), for: .touchUpInside)
        closeButton.setTitle("close", for: .normal)
        closeButton.setTitleColor(.label, for: .normal)
        
        makeLabel.font = UIFont.systemFont(ofSize: 18)
        makeLabel.textColor = .label
        makeLabel.textAlignment = .left
        
        focalLabel.font = UIFont.systemFont(ofSize: 18)
        focalLabel.textColor = .label
        focalLabel.textAlignment = .left
        
        modelLabel.font = UIFont.systemFont(ofSize: 18)
        modelLabel.textColor = .label
        modelLabel.textAlignment = .left
        
        isoLabel.font = UIFont.systemFont(ofSize: 18)
        isoLabel.textColor = .label
        isoLabel.textAlignment = .left
        
//        shutterLabel.font = UIFont.systemFont(ofSize: 16)
//        shutterLabel.textColor = .white
//        shutterLabel.textAlignment = .left
        
        dimensionLabel.font = UIFont.systemFont(ofSize: 18)
        dimensionLabel.textColor = .label
        dimensionLabel.textAlignment = .left
        
        apertureLabel.font = UIFont.systemFont(ofSize: 18)
        apertureLabel.textColor = .label
        apertureLabel.textAlignment = .left
        
        publishedLabel.font = UIFont.systemFont(ofSize: 18)
        publishedLabel.textColor = .label
        publishedLabel.textAlignment = .left
      
        self.addSubview(titleLabel)
        self.addSubview(mapImageView)
        self.addSubview(locationLabel)
        self.addSubview(closeButton)
        self.addSubview(makeLabel)
        self.addSubview(focalLabel)
        self.addSubview(modelLabel)
        self.addSubview(isoLabel)
        //self.addSubview(shutterLabel)
        self.addSubview(dimensionLabel)
        self.addSubview(apertureLabel)
        self.addSubview(publishedLabel)
        self.addSubview(descriptionLabel)
        
        configureConstraints()
    }
    
    func configureConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        mapImageView.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        makeLabel.translatesAutoresizingMaskIntoConstraints = false
        focalLabel.translatesAutoresizingMaskIntoConstraints = false
        modelLabel.translatesAutoresizingMaskIntoConstraints = false
        isoLabel.translatesAutoresizingMaskIntoConstraints = false
        //shutterLabel.translatesAutoresizingMaskIntoConstraints = false
        dimensionLabel.translatesAutoresizingMaskIntoConstraints = false
        apertureLabel.translatesAutoresizingMaskIntoConstraints = false
        publishedLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionConstraint = descriptionLabel.heightAnchor.constraint(equalToConstant: 22)
        
        NSLayoutConstraint.activate([
            
            closeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            closeButton.topAnchor.constraint(equalTo: self.topAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 44),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            descriptionConstraint,
            
            mapImageView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant: 10),
            mapImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            mapImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            mapImageView.heightAnchor.constraint(equalToConstant: 300),
            
            locationLabel.topAnchor.constraint(equalTo: mapImageView.bottomAnchor,constant: 5),
            locationLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            locationLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            locationLabel.heightAnchor.constraint(equalToConstant: 24),
            
            makeLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor,constant: 5),
            makeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            makeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            makeLabel.heightAnchor.constraint(equalToConstant: 22),
            
            focalLabel.topAnchor.constraint(equalTo: makeLabel.bottomAnchor,constant: 5),
            focalLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            focalLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            focalLabel.heightAnchor.constraint(equalToConstant: 22),
            
            modelLabel.topAnchor.constraint(equalTo: focalLabel.bottomAnchor,constant: 5),
            modelLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            modelLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            modelLabel.heightAnchor.constraint(equalToConstant: 22),
            
            isoLabel.topAnchor.constraint(equalTo: modelLabel.bottomAnchor,constant: 5),
            isoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            isoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            isoLabel.heightAnchor.constraint(equalToConstant: 22),
           
            dimensionLabel.topAnchor.constraint(equalTo: isoLabel.bottomAnchor,constant: 5),
            dimensionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            dimensionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            dimensionLabel.heightAnchor.constraint(equalToConstant: 22),
            
            apertureLabel.topAnchor.constraint(equalTo: dimensionLabel.bottomAnchor,constant: 5),
            apertureLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            apertureLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            apertureLabel.heightAnchor.constraint(equalToConstant: 22),
            
            publishedLabel.topAnchor.constraint(equalTo: apertureLabel.bottomAnchor,constant: 5),
            publishedLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            publishedLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            publishedLabel.heightAnchor.constraint(equalToConstant: 22),
            
        ])
    }
}

// MARK:- Action
extension PhotoExifView {
    @objc func closeButtonTouch() {
        photoExifViewDelegate.userDidTouchCloseButton()
    }
}


