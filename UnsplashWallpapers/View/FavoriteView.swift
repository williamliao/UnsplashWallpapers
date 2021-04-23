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
    private func getDatasource() -> UITableViewDiffableDataSource<FavoriteSection, Response> {
        return dataSource
    }
    
    @available(iOS 13.0, *)
    func makeDataSource() -> UITableViewDiffableDataSource<FavoriteSection, Response> {
        
        return UITableViewDiffableDataSource<FavoriteSection, Response>(tableView: tableView) { (tableView, indexPath, respone) -> FavoriteTableViewCell? in
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
        
        var snapshot = NSDiffableDataSourceSnapshot<FavoriteSection, Response>()
        
        //Append available sections
        FavoriteSection.allCases.forEach { snapshot.appendSections([$0]) }
        dataSource.apply(snapshot, animatingDifferences: false)
        
        //Append annotations to their corresponding sections
        
        viewModel.respone.value?.forEach { (respone) in
            snapshot.appendItems([respone], toSection: .main)
        }
        
        //Force the update on the main thread to silence a warning about collectionView not being in the hierarchy!
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
}

extension FavoriteView {
    
    func configureTableView(Add to: UIView) {
        to.backgroundColor = .systemBackground
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    func configureCell(tableView: UITableView, respone: Response, indexPath: IndexPath) -> FavoriteTableViewCell? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTableViewCell.reuseIdentifier, for: indexPath) as? FavoriteTableViewCell
        
        cell?.titleLabel.text = respone.user?.name
        
        if let url = URL(string: respone.urls.thumb) {
            cell?.configureImage(with: url)
        }
        
        if let url = URL(string: respone.user?.profile_image.small ?? "") {
            cell?.configureAImage(with: url)
        }
        
        return cell
    }
}

extension FavoriteView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
