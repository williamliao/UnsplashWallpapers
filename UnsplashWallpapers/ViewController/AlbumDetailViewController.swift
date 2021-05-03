//
//  AlbumDetailViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/3.
//

import UIKit

class AlbumDetailViewController: UIViewController {
    
    var viewModel: AlbumDetailViewModel!
    var albumDetailView: AlbumDetailView!

    override func viewDidLoad() {
        super.viewDidLoad()

        albumDetailView = AlbumDetailView(viewModel: viewModel, coordinator: viewModel.coordinator)
        albumDetailView.translatesAutoresizingMaskIntoConstraints = false
        albumDetailView.configureCollectionView()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(albumDetailView)
        
        let guide = self.view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            
            albumDetailView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            albumDetailView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            albumDetailView.topAnchor.constraint(equalTo: guide.topAnchor),
            albumDetailView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
         
        ])
        
        
        
        viewModel.detailRespone.bind { [weak self] (_) in
            
            self?.albumDetailView.configureDataSource()
            
        }
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
