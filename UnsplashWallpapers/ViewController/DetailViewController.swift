//
//  DetailViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/22.
//

import UIKit

class DetailViewController: UIViewController {
    var viewModel: DetailViewModel!
    var detailView: DetailView!

    override func viewDidLoad() {
        super.viewDidLoad()
        detailView = DetailView(viewModel: viewModel)
        detailView.translatesAutoresizingMaskIntoConstraints = false
        detailView.createView()
        detailView.observerBindData()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(detailView)
        
        let guide = self.view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            detailView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            detailView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            detailView.topAnchor.constraint(equalTo: guide.topAnchor),
            detailView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
         
        ])
        
        self.viewModel.navItem = self.navigationItem
        self.viewModel.createBarItem()
        self.viewModel.loadFavorite()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
