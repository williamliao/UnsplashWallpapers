//
//  SearchView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/26.
//

import UIKit

enum SearchViewCurrentSource: Int, CaseIterable {
    case photos
    case collections
    case user
}

class SearchView: UIView {
    
    var searchViewController: UISearchController!
    var collectionView: UICollectionView!
    var navItem: UINavigationItem!
    var viewModel: SearchViewModel
    var coordinator: MainCoordinator?
    
    var resultsViewModel: SearchResultsViewModel!
    var searchResultsView: SearchResultsTableView!
    
    var currentSource: SearchViewCurrentSource = .photos
    
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
    
    @available(iOS 13.0, *)
    lazy var searchUserDataSource  = makeSearchUserDataSource()
    
    
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
        searchViewController.searchBar.scopeButtonTitles = SearchResults.Category.allCases.map { $0.rawValue }
        searchViewController.searchBar.showsScopeBar = true
        searchViewController.isActive = true
        
        
        if #available(iOS 11.0, *) {
            navItem.searchController = searchViewController
            searchViewController.hidesNavigationBarDuringPresentation = false
            navItem.hidesSearchBarWhenScrolling = false
        } else {
            navItem.titleView = searchViewController.searchBar
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
        collectionView.register(UsersListCollectionViewCell.self
                                , forCellWithReuseIdentifier: UsersListCollectionViewCell.reuseIdentifier)
        
        
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
        searchResultsView.backgroundColor = .systemBackground
        
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
    
    @available(iOS 13.0, *)
    private func getSearchUserDatasource() -> UICollectionViewDiffableDataSource<Section, Results> {
        return searchUserDataSource
    }
    
    func makeSearchDataSource() -> UICollectionViewDiffableDataSource<Section, Results> {
        return UICollectionViewDiffableDataSource<Section, Results>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            let cell = self.configureSearchCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    func makeSearchUserDataSource() -> UICollectionViewDiffableDataSource<Section, Results> {
        return UICollectionViewDiffableDataSource<Section, Results>(collectionView: collectionView) { (collectionView, indexPath, respone) -> UsersListCollectionViewCell? in
            let cell = self.configureSearchUserCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {

        var snapshot = NSDiffableDataSourceSnapshot<Section, Results>()
        var dataSource = getSearchDatasource()
        
        switch currentSource {
        case .photos, .collections:
            collectionView.dataSource = dataSource
            break
        case .user:
            dataSource = getSearchUserDatasource()
            collectionView.dataSource = dataSource
            break
        }
        
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
            
            self.searchViewController.isActive = false
            
            if let count = self.viewModel.searchRespone.value?.results.count {
                if count > 0 {
                    self.searchResultsView.isHidden = true
                }
            }
        }
    }
    
    func configureSearchCell(collectionView: UICollectionView, respone: Results, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        cell?.titleLabel.text = respone.user?.name
        
        if viewModel.category == .photos {
            if let url = URL(string: respone.urls?.small ?? "") {
                cell?.configureImage(with: url)
            }
        } else if viewModel.category == .collections {
            if let url = URL(string: respone.cover_photo?.urls.small ?? "") {
                cell?.configureImage(with: url)
            }
        }
    
        return cell
    }
    
    func configureSearchUserCell(collectionView: UICollectionView, respone: Results, indexPath: IndexPath) -> UsersListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UsersListCollectionViewCell.reuseIdentifier, for: indexPath) as? UsersListCollectionViewCell
        
        cell?.titleLabel.text = respone.name
        if let url = URL(string: respone.profile_image?.small ?? "") {
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
        
        if viewModel.category == .users {
            return CGSize(width: collectionView.bounds.size.width, height: 50)
        } else {
            return CGSize(width: collectionView.bounds.size.width, height: 300)
        }
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
        
        guard let category = SearchResults.Category(rawValue:searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]) else {
            return
        }
        
        viewModel.search(keyword: strippedString, category: category)
        let searchResults = SearchResults(title: strippedString, category: category)
        
        if resultsViewModel.searchHistory.value.count > 0 {
            for sr in resultsViewModel.searchHistory.value {
                if sr.title != searchResults.title {
                    resultsViewModel.searchHistory.value.insert(searchResults)
                }
            }
        } else {
            resultsViewModel.searchHistory.value.insert(searchResults)
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
        
        switch selectedScope {
            case 0:
                currentSource = .photos
            case 1:
                currentSource = .collections
            case 2:
                currentSource = .user
            default:
                break
        }
        
        guard let scopeButtonTitles = searchBar.scopeButtonTitles else {
            return
        }
        
        guard let category = SearchResults.Category(rawValue:
                                                        scopeButtonTitles[selectedScope]) else {
            return
        }
        
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
        
        viewModel.reset()
        viewModel.search(keyword: strippedString, category: category)
    }
}

// MARK: - UICollectionViewDelegate

extension SearchView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if #available(iOS 13.0, *) {
            
            switch viewModel.category {
            case .photos:
                guard let res = searchDataSource.itemIdentifier(for: indexPath), let urls = res.urls, let user = res.user, let width = res.width, let height = res.height  else {
                    return
                }
                
                let photoInfo = PhotoInfo(id: res.id, title: user.name, url: urls, profile_image: user.profile_image, width: CGFloat(width), height: CGFloat(height))
                coordinator?.goToDetailView(photoInfo: photoInfo)
            case .collections:
                
                guard let res = searchDataSource.itemIdentifier(for: indexPath) else {
                    return
                }
                
               /* let searchBar = searchViewController.searchBar
                
                guard let scopeButtonTitles = searchViewController.searchBar.scopeButtonTitles else {
                    return
                }
                
                guard let category = SearchResults.Category(rawValue:
                                                                scopeButtonTitles[searchBar.selectedScopeButtonIndex]) else {
                    return
                }*/
                
                coordinator?.pushToCollectionListView(id: res.id)
                break
                
            case .users:
                
                guard let res = searchUserDataSource.itemIdentifier(for: indexPath), let userName = res.username, let name = res.name, let profile_image = res.profile_image else {
                    return
                }
                let userProfileInfo = UserProfileInfo(id: UUID(), name: name, userName: userName, profile_image: profile_image)
                coordinator?.pushToUserProfileCollectionListView(userProfileInfo: userProfileInfo)
                break
                
            default:
                break
            
            }
            
            
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
    func searchResultsDidSelected(query: String, category: SearchResults.Category) {
        
        switch category {
            case .photos:
                searchViewController.searchBar.selectedScopeButtonIndex = 0
                currentSource = .photos
            case .collections:
                searchViewController.searchBar.selectedScopeButtonIndex = 1
                currentSource = .collections
            case .users:
                searchViewController.searchBar.selectedScopeButtonIndex = 2
                currentSource = .user
        }
        
        viewModel.search(keyword: query, category: category)
    }
}
