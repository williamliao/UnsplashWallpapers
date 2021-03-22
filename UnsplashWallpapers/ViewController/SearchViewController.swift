//
//  SearchViewController.swift
//  CandyWithMVVMC
//
//  Created by William on 2020/12/25.
//  Copyright © 2020 William. All rights reserved.
//

import UIKit

class SearchViewController: UISearchController {
    
    var viewModel: PhotoListViewModel!
    init(viewModel: PhotoListViewModel) {
        self.viewModel = viewModel
        super.init(searchResultsController: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var isSearchBarEmpty: Bool {
        return self.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = self.searchBar.selectedScopeButtonIndex != 0
        return self.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        //self.searchResultsUpdater = self
        self.searchBar.autocapitalizationType = .none
        //self.dimsBackgroundDuringPresentation = false
        self.searchBar.delegate = self
        self.searchBar.sizeToFit()
        self.obscuresBackgroundDuringPresentation = true
        self.searchBar.placeholder = "Search Candies"
        definesPresentationContext = true
       // self.showsSearchResultsController = true
        //self.searchBar.scopeButtonTitles = SearchItem.ScopeTypeSection.allCases.map { $0.rawValue }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text.isEmptyOrWhitespace() {
            return
        }
        
        guard let searchText = searchBar.text else {
            return
        }
        
        // Strip out all the leading and trailing spaces.
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString =
            searchText.trimmingCharacters(in: whitespaceCharacterSet)
        
        viewModel.search(keyword: strippedString)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        closeSearchView()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            closeSearchView()
        }
    }
    
    func closeSearchView() {
        self.viewModel.didCloseSearchFunction()
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
}
