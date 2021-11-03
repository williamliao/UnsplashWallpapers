//
//  FavoriteView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/22.
//

import UIKit

enum FavoriteSection: Int, CaseIterable {
  case main
}

class FavoriteView: UIView {
    let viewModel: FavoriteViewModel
    
    init(viewModel: FavoriteViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tableView: UITableView!
    
    // MARK:- property
    var firstLoad = true
    
    @available(iOS 13.0, *)
    lazy var dataSource  = makeDataSource()
}

extension FavoriteView {
    
    @available(iOS 13.0, *)
    private func getDatasource() -> UITableViewDiffableDataSource<FavoriteSection, PhotoInfo> {
        return dataSource
    }
    
    @available(iOS 13.0, *)
    func makeDataSource() -> UITableViewDiffableDataSource<FavoriteSection, PhotoInfo> {
        
        return UITableViewDiffableDataSource<FavoriteSection, PhotoInfo>(tableView: tableView) { (tableView, indexPath, respone) -> FavoriteTableViewCell? in
            let cell = self.configureCell(tableView: tableView, respone: respone, indexPath: indexPath)
            return cell
        }
    }
    
    func makeDateSourceForTableView() {
        if #available(iOS 13.0, *) {
           
            if (!firstLoad) {
                dataSource = makeDataSource()
                tableView.dataSource = dataSource
                return
            }
            
            tableView.dataSource = dataSource
            firstLoad = false
            
        } else {
            //tableView.dataSource = self
        }
        
        tableView.delegate = self
    }
    
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        if (!firstLoad) {
            dataSource = makeDataSource()
        } else {
            dataSource = getDatasource()
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<FavoriteSection, PhotoInfo>()
        
        //Append available sections
        FavoriteSection.allCases.forEach { snapshot.appendSections([$0]) }
        dataSource.apply(snapshot, animatingDifferences: false)
        
        //Append annotations to their corresponding sections
        
        viewModel.photoInfo.value?.forEach { (respone) in
            snapshot.appendItems([respone], toSection: .main)
        }
        
        UIView.performWithoutAnimation {
            //Force the update on the main thread to silence a warning about collectionView not being in the hierarchy!
            DispatchQueue.main.async {
                //self.collectionView.setNeedsLayout()
                self.dataSource.apply(snapshot, animatingDifferences: false)
                self.tableView.layoutIfNeeded()
            }
        }
    }
}

extension FavoriteView {
    
    func configureTableView(Add to: UIView) {
        //to.backgroundColor = .systemBackground
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        //tableView.backgroundColor = .systemBackground
        
        tableView.register(FavoriteTableViewCell.self, forCellReuseIdentifier: FavoriteTableViewCell.reuseIdentifier)
        
        to.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: to.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: to.safeAreaLayoutGuide.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: to.safeAreaLayoutGuide.topAnchor),
        ])
    }
}

// MARK: - Private
extension FavoriteView {
    
    func configureCell(tableView: UITableView, respone: PhotoInfo, indexPath: IndexPath) -> FavoriteTableViewCell? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTableViewCell.reuseIdentifier, for: indexPath) as? FavoriteTableViewCell
        
        cell?.titleLabel.text = respone.title
        
        if let url = URL(string: respone.url.regular) {
            cell?.configureImage(with: url)
        }
        
        if let url = URL(string: respone.profile_image.small) {
            cell?.configureAImage(with: url)
        }
        
        return cell
    }
}

extension FavoriteView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let photoInfo = dataSource.itemIdentifier(for: indexPath) else {
            return 200
        }
         
        let height = photoInfo.height
        let width = photoInfo.width
        
        if height > width {
            let resizeH = CGFloat(height) / 8
            
            let resizeHeight: CGFloat = CGFloat(resizeH)
            
            return resizeHeight
        } else {
            return 200
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //1
        guard let photoInfo = dataSource.itemIdentifier(for: indexPath) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        

        //Update title
        var updatePhotoInfo = photoInfo
        updatePhotoInfo.title = updatePhotoInfo.title.appending(" ★")
        
        viewModel.photoInfo.value?[indexPath.row] = updatePhotoInfo
       
        let favoriteManager = FavoriteManager.sharedInstance
        
        // Replacing photoInfo with updatePhotoInfo
        UIView.setAnimationsEnabled(false)
        CATransaction.begin()

        CATransaction.setCompletionBlock { () -> Void in
            UIView.setAnimationsEnabled(true)
        }
        
        var newSnapshot = dataSource.snapshot()

        //self.reloadItems(newItems:updatePhotoInfo, deleteItems: photoInfo)
        if #available(iOS 15, *) {
            // iOS 15
            newSnapshot.reconfigureItems([photoInfo])
        } else {
            // iOS 14
            newSnapshot.reloadItems([photoInfo])
            //self.handleNewItems([updatePhotoInfo])
        }
        
        // Apply `newSnapshot` to data source so that the changes will be reflected in the collection view.
        if #available(iOS 15.0, *) {
            dataSource.applySnapshotUsingReloadData(newSnapshot)
        } else {
            // Fallback on earlier versions
            dataSource.apply(newSnapshot)
        }
        
        if favoriteManager.favorites.value.contains(photoInfo) {
            favoriteManager.favorites.value.remove(photoInfo)
        }
        
        favoriteManager.handleSaveAction(photo: updatePhotoInfo, isFavorite: true)
        favoriteManager.saveToFavorite()
    
        CATransaction.commit()
    }
    
    func reloadItems( newItems: PhotoInfo, deleteItems: PhotoInfo) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([newItems], toSection: FavoriteSection.main)
        snapshot.deleteItems([deleteItems])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func handleNewItems(_ newItems: [PhotoInfo]) {
        var snapShot = dataSource.snapshot()
        let diff = newItems.difference(from: snapShot.itemIdentifiers)
        let currentIdentifiers = snapShot.itemIdentifiers
        guard let newIdentifiers = currentIdentifiers.applying(diff) else {
            return
        }
        snapShot.deleteItems(currentIdentifiers)
        snapShot.appendItems(newIdentifiers)
        dataSource.apply(snapShot, animatingDifferences: true)
    }
}
