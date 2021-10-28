//
//  SettingViewController.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/8/25.
//

import UIKit

class SettingViewController: UIViewController {
    
    var settingListView: SettingView!

    override func viewDidLoad() {
        super.viewDidLoad()

        settingListView = SettingView()
        settingListView.configureHierarchy()
        settingListView.configureDataSource()
        settingListView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.backgroundColor = .systemBackground
        
        self.view.addSubview(settingListView)
        
        NSLayoutConstraint.activate([
            settingListView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            settingListView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            settingListView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            settingListView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])
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
