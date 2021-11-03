//
//  SearchViewController.swift
//  CandyWithMVVMC
//
//  Created by William on 2020/12/25.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    var viewModel: SearchViewModel!
    var searchView: SearchView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchView = SearchView(viewModel: viewModel, coordinator: viewModel.coordinator)
        searchView.navItem = self.navigationItem
        searchView.createView()
        searchView.configureCollectionView()
        searchView.createTrendingView()
        searchView.translatesAutoresizingMaskIntoConstraints = false
        
        //self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(searchView)
        
        NSLayoutConstraint.activate([
            searchView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            searchView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            searchView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])
        
        viewModel.searchRespone.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.searchView.applyInitialSnapshots()
            } else {
                //self?.searchView.reloadData()
            }
        }
        
        viewModel.error.bind { (error) in
            guard let error = error else {
                return
            }
            
            print("search error", error)
        }
    }
}
