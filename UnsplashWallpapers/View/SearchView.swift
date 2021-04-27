//
//  SearchView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/26.
//

import UIKit

class SearchView: UIView {
    
    var searchViewController: UISearchController!
    var collectionView: UICollectionView!
    var navItem: UINavigationItem!
    var viewModel: SearchViewModel
    var coordinator: MainCoordinator?
    
    var resultsViewModel: SearchResultsViewModel!
    var searchResultsView: SearchResultsTableView!
    
    init(viewModel: SearchViewModel,coordinator: MainCoordinator? ) {
        self.viewModel = viewModel
        self.coordinator = viewModel.coordinator
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(iOS 13.0, *)
    lazy var searchDataSource  = makeSearchDataSource()
    
    var firstLoad = true
    var currentIndex = 0;
}

// MARK: - View
extension SearchView {
    func createView() {
        self.backgroundColor = .systemBackground
        
        searchViewController = UISearchController(searchResultsController: nil)
        searchViewController.searchBar.delegate = self
        searchViewController.obscuresBackgroundDuringPresentation = true
        searchViewController.searchBar.placeholder = "Search"
        searchViewController.definesPresentationContext = true
        searchViewController.searchBar.autocapitalizationType = .none
        //searchViewController.searchBar.sizeToFit()
        searchViewController.obscuresBackgroundDuringPresentation = true
        // self.showsSearchResultsController = true
         //self.searchBar.scopeButtonTitles = SearchItem.ScopeTypeSection.allCases.map { $0.rawValue }
        searchViewController.isActive = true
        
        if #available(iOS 11.0, *) {
            navItem.searchController = searchViewController
            searchViewController.hidesNavigationBarDuringPresentation = false
            navItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    func configureCollectionView() {
       
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.estimatedItemSize = .zero

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.delegate = self
        //collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        makeDateSourceForCollectionView()
        
        collectionView.register(PhotoListCollectionViewCell.self
                                , forCellWithReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier)
        
        self.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
    }
    
    func makeDateSourceForCollectionView() {
        if #available(iOS 13.0, *) {
           
            if (!firstLoad) {
                searchDataSource = makeSearchDataSource()
                collectionView.dataSource = searchDataSource
                return
            }
            
            collectionView.dataSource = searchDataSource
            firstLoad = false
            
        } else {
            //collectionView.dataSource = self
        }
    }
    
    func createTrendingView() {
        resultsViewModel = SearchResultsViewModel()
        resultsViewModel.setupDefaultTrending()
        resultsViewModel.loadSearchHistory(key: "searchHistory") { (_) in
            
        }

        searchResultsView = SearchResultsTableView(viewModel: resultsViewModel)
        searchResultsView.createView()
        searchResultsView.translatesAutoresizingMaskIntoConstraints = false
        searchResultsView.searchResultsDidSelectedDelegate = self
        
        self.addSubview(searchResultsView)
        
        NSLayoutConstraint.activate([
            searchResultsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            searchResultsView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            searchResultsView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            searchResultsView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
        
        resultsViewModel.trending.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.searchResultsView.applyInitialSnapshots()
            } else {
                self?.searchResultsView.tableView.reloadData()
            }
        }
        
        resultsViewModel.searchHistory.bind { [weak self] (_) in
            if #available(iOS 13.0, *) {
                self?.searchResultsView.applyInitialSnapshots()
            } else {
                self?.searchResultsView.tableView.reloadData()
            }
        }
    }
}

// MARK: - Private
extension SearchView {
    
    @available(iOS 13.0, *)
    private func getSearchDatasource() -> UICollectionViewDiffableDataSource<Section, Results> {
        return searchDataSource
    }
    
    func makeSearchDataSource() -> UICollectionViewDiffableDataSource<Section, Results> {
        
        return UICollectionViewDiffableDataSource<Section, Results>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            let cell = self.configureSearchCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        
        let dataSource = getSearchDatasource()
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Results>()
        
        //Append available sections
        Section.allCases.forEach { snapshot.appendSections([$0]) }
        dataSource.apply(snapshot, animatingDifferences: false)
        
        //Append annotations to their corresponding sections
        
        viewModel.searchRespone.value?.results.forEach { (result) in
            snapshot.appendItems([result], toSection: .main)
        }
        
        //Force the update on the main thread to silence a warning about tableview not being in the hierarchy!
        DispatchQueue.main.async {
            dataSource.apply(snapshot, animatingDifferences: false)
            
            if let count = self.viewModel.searchRespone.value?.results.count {
                if count > 0 {
                    self.searchResultsView.isHidden = true
                }
            }
        }
    }
    
    func configureSearchCell(collectionView: UICollectionView, respone: Results, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        cell?.titleLabel.text = respone.user.name
        
        if let url = URL(string: respone.urls.thumb) {
            cell?.configureImage(with: url)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - UISearchBarDelegate

extension SearchView: UISearchBarDelegate {
   
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
        if !resultsViewModel.searchHistory.value.contains(SearchResults(title: strippedString)) {
            resultsViewModel.searchHistory.value.insert(SearchResults(title: strippedString))
        }
        resultsViewModel.saveSearchHistory()
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
        searchResultsView.isHidden = false
        viewModel.searchRespone.value = nil
        self.viewModel.didCloseSearchFunction()
        self.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
    }
}

// MARK: - UICollectionViewDelegate

extension SearchView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if #available(iOS 13.0, *) {
            
            guard let res = searchDataSource.itemIdentifier(for: indexPath)  else {
                return
            }
            
            let photoInfo = PhotoInfo(title: res.user.name, url: res.urls, profile_image: res.user.profile_image)
            coordinator?.goToDetailView(photoInfo: photoInfo)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let lastElement = collectionView.numberOfItems(inSection: indexPath.section) - 1
        if !viewModel.isLoading.value && indexPath.row == lastElement {
        
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: collectionView.bounds.width, height: CGFloat(44))

            currentIndex = lastElement
            viewModel.fetchNextPage()
            
        }
    }
}

// MARK: - SearchResultsDidSelectedDelegate

extension SearchView: SearchResultsDidSelectedDelegate {
    func searchResultsDidSelected(query: String) {
        viewModel.search(keyword: query)
    }
}
