//
//  UserProfileViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/28.
//

import UIKit

class UserProfileViewController: UIViewController {
    
    var viewModel: UserProfileViewModel!
    var userProfileView: UserProfileView!

    override func viewDidLoad() {
        super.viewDidLoad()

        userProfileView = UserProfileView(viewModel: viewModel, coordinator: viewModel.coordinator)
        userProfileView.configureCollectionView()
        userProfileView.createUserProfileHeaderView()
        userProfileView.createSegmentView()
        userProfileView.configureConstraints()
        userProfileView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(userProfileView)
        
        NSLayoutConstraint.activate([
            userProfileView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            userProfileView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            userProfileView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            userProfileView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])
        
        viewModel.userPhotosResponse.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.userProfileView.applyInitialSnapshots()
            } else {
                //self?.searchView.reloadData()
            }
        }
        
        viewModel.userLikesResponse.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.userProfileView.applyInitialSnapshots()
            } else {
                //self?.searchView.reloadData()
            }
        }
        
        viewModel.userCollectionsResponse.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.userProfileView.applyInitialSnapshots()
            } else {
                //self?.searchView.reloadData()
            }
        }
        
        viewModel.error.bind { (error) in
            guard let error = error else {
                return
            }
            
            print("UserProfileViewController error", error)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.cancelWhenViewDidDisappear()
    }

}
