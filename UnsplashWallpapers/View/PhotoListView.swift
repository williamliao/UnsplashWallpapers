//
//  PhotoListView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import UIKit

enum Section: Int, CaseIterable {
  case main
}

class PhotoListView: UIView {
    
    // MARK: - component
    var collectionView: UICollectionView!
    
    var viewModel: PhotoListViewModel
    
    @available(iOS 13.0, *)
    lazy var dataSource  = makeDataSource()
    
    @available(iOS 13.0, *)
    lazy var searchDataSource  = makeSearchDataSource()
    
    var coordinator: MainCoordinator?
    
    var searchButton: UIButton!
    
    // MARK:- property
    var firstLoad = true
    
    init(viewModel: PhotoListViewModel, coordinator: MainCoordinator?) {
        self.viewModel = viewModel
        self.coordinator = viewModel.coordinator
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PhotoListView {
    
    func configureCollectionView(Add to: UIView) {
       
        to.backgroundColor = .systemBackground
        
        let flowLayout = UICollectionViewFlowLayout()
       
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        
        collectionView.delegate = self
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        makeDateSourceForCollectionView()
        
        collectionView.register(PhotoListCollectionViewCell.self
                                , forCellWithReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier)
        
        to.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: to.safeAreaLayoutGuide.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: to.safeAreaLayoutGuide.topAnchor),
        ])
    }
    
    func makeDateSourceForCollectionView() {
        if #available(iOS 13.0, *) {
           
            if (!firstLoad) {
                dataSource = makeDataSource()
                collectionView.dataSource = dataSource
                return
            }
            
            collectionView.dataSource = dataSource
            firstLoad = false
            
        } else {
            collectionView.dataSource = self
        }
    }
    
    func createSearchBarItem(navItem: UINavigationItem) {
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        navItem.rightBarButtonItem = barButton
    }
    
    @objc func searchButtonTapped() {
        viewModel.search(keyword: "nature")
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoListView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

       /* let cellsPerRow = 1
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize(width: 0, height: 0) }
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        return CGSize(width: itemWidth, height: 300)*/
        
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

// MARK: - UICollectionViewDiffableDataSource
extension PhotoListView {
    
    @available(iOS 13.0, *)
    private func getDatasource() -> UICollectionViewDiffableDataSource<Section, UnsplashPhoto> {
        return dataSource
    }
    
    @available(iOS 13.0, *)
    private func getSearchDatasource() -> UICollectionViewDiffableDataSource<Section, Results> {
        return searchDataSource
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, UnsplashPhoto> {
        
        return UICollectionViewDiffableDataSource<Section, UnsplashPhoto>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            let cell = self.configureCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    func makeSearchDataSource() -> UICollectionViewDiffableDataSource<Section, Results> {
        
        return UICollectionViewDiffableDataSource<Section, Results>(collectionView: collectionView) { (collectionView, indexPath, respone) -> PhotoListCollectionViewCell? in
            let cell = self.configureSearchCell(collectionView: collectionView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        
        
        if (viewModel.isSearching.value) {
            
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
            }
            
        } else {
            
            if (!firstLoad) {
                dataSource = makeDataSource()
            } else {
                dataSource = getDatasource()
            }
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, UnsplashPhoto>()
            
            //Append available sections
            Section.allCases.forEach { snapshot.appendSections([$0]) }
            dataSource.apply(snapshot, animatingDifferences: false)
            
            //Append annotations to their corresponding sections
            
            viewModel.respone.value?.forEach { (respone) in
                snapshot.appendItems([respone], toSection: .main)
            }
            
            //Force the update on the main thread to silence a warning about tableview not being in the hierarchy!
            DispatchQueue.main.async {
                self.dataSource.apply(snapshot, animatingDifferences: false)
            }
        }
        
        
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoListView: UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let count = viewModel.respone.value?.count else {
          return 0
        }
        
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let res = viewModel.respone.value else {
          return UICollectionViewCell()
        }
        
        guard let cell = self.configureCell(collectionView: collectionView, respone: res[indexPath.row], indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        return cell
    }

}

// MARK: - UICollectionViewDelegate
extension PhotoListView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if #available(iOS 13.0, *) {
            guard let res = dataSource.itemIdentifier(for: indexPath) else {
              return
            }
           // coordinator?.goToDetailView(respone: res)
        } else {
            guard let res = viewModel.respone.value?[indexPath.row] else {
                return
            }
            //coordinator?.goToDetailView(respone: res)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let result = viewModel.searchRespone.value?.results else {
            return
        }
        
        print("indexPath row, \(indexPath.row)")
        
        let lastElement = collectionView.numberOfItems(inSection: indexPath.section) - 1
        if !viewModel.isLoading.value && indexPath.row == lastElement {
           // indicator.startAnimating()
            viewModel.isLoading.value = true
            //currentPage =  currentPage + 1
            
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: collectionView.bounds.width, height: CGFloat(44))

            
            viewModel.fetchNextPage()
            
        }
    }
}


// MARK: - Private
extension PhotoListView {
    
    func configureCell(collectionView: UICollectionView, respone: UnsplashPhoto, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        cell?.titleLabel.text = respone.user.name
        
        if let url = respone.urls[.thumb] {
            cell?.configureImage(with: url)
        }
        
        return cell
    }
    
    func configureSearchCell(collectionView: UICollectionView, respone: Results, indexPath: IndexPath) -> PhotoListCollectionViewCell? {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoListCollectionViewCell.reuseIdentifier, for: indexPath) as? PhotoListCollectionViewCell
        
        cell?.titleLabel.text = respone.user.name
        
        if let url = respone.urls[.thumb] {
            cell?.configureImage(with: url)
        }
        
        return cell
    }
}
