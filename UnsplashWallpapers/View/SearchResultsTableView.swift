//
//  SearchResultsTableView.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/27.
//

import UIKit

enum SearchResultsSection: Int, CaseIterable {
    case recent
    case trending
}

protocol SearchResultsDidSelectedDelegate: class {
    func searchResultsDidSelected(query:String, category: SearchResults.Category)
}

class SearchResultsTableView: UIView {
    var tableView: UITableView!
    var viewModel: SearchResultsViewModel
    
    weak var searchResultsDidSelectedDelegate: SearchResultsDidSelectedDelegate!
    
    var firstLoad: Bool = true
    
    @available(iOS 13.0, *)
    lazy var dataSource  = makeDataSource()
    
    init(viewModel: SearchResultsViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchResultsTableView {
    func createView() {
        self.backgroundColor = .systemBackground
        
        tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        
        tableView.delegate = self
        //tableView.contentInsetAdjustmentBehavior = .always
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        makeDateSourceForTableView()
        
        tableView.register(SearchResultsTableViewCell.self, forCellReuseIdentifier: SearchResultsTableViewCell.reuseIdentifier)
        tableView.register(SearchResultsHeaderView.self, forHeaderFooterViewReuseIdentifier: SearchResultsHeaderView.reuseIdentifier)
        
        self.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
        ])
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
    }
    
    @available(iOS 13.0, *)
    private func getDatasource() -> UITableViewDiffableDataSource<SearchResultsSection, SearchResults> {
        return dataSource
    }
    
    @available(iOS 13.0, *)
    func makeDataSource() -> UITableViewDiffableDataSource<SearchResultsSection, SearchResults> {
        
        return UITableViewDiffableDataSource<SearchResultsSection, SearchResults>(tableView: tableView) { (tableView, indexPath, trending) -> SearchResultsTableViewCell? in
            let cell = self.configureCell(tableView: tableView, trending: trending, indexPath: indexPath)
            return cell
        }
    }
    
    @available(iOS 13.0, *)
    func applyInitialSnapshots() {
        
        let dataSource = getDatasource()
        
        var snapshot = NSDiffableDataSourceSnapshot<SearchResultsSection, SearchResults>()
        
        //Append available sections
        SearchResultsSection.allCases.forEach { snapshot.appendSections([$0]) }
        dataSource.apply(snapshot, animatingDifferences: false)
        
        //Append annotations to their corresponding sections
        
        viewModel.trending.value?.forEach { (trending) in
            snapshot.appendItems([trending], toSection: .trending)
        }
        
        viewModel.searchHistory.value.forEach { (history) in
            snapshot.appendItems([history], toSection: .recent)
        }
        
        //Force the update on the main thread to silence a warning about tableview not being in the hierarchy!
        DispatchQueue.main.async {
            dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    func configureCell(tableView: UITableView, trending: SearchResults, indexPath: IndexPath) -> SearchResultsTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTableViewCell.reuseIdentifier, for: indexPath) as? SearchResultsTableViewCell
        
        cell?.titleLabel.text = trending.title
        
        return cell
    }
}

extension SearchResultsTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: SearchResultsHeaderView.reuseIdentifier) as! SearchResultsHeaderView
        
        switch section {
            case 0:
                header.titleLabel.text = "Recent"
            case 1:
                header.titleLabel.text = "Trending"
            default:
                break
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            
            let querys = Array(viewModel.searchHistory.value)
            
            searchResultsDidSelectedDelegate.searchResultsDidSelected(query: querys[indexPath.row].title, category: querys[indexPath.row].category)
        case 1:
            guard let querys = viewModel.trending.value else {
                return
            }

            searchResultsDidSelectedDelegate.searchResultsDidSelected(query: querys[indexPath.row].title, category: querys[indexPath.row].category)
        default:
            break
        }
        
        
    }
}
