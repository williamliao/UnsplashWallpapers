//
//  NetworkConnectivityManager.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/7.
//

import Network

class NetworkConnectivityManager {
    private let networkMonitor: NWPathMonitor = NWPathMonitor()
    private var networkMonitorQueue: DispatchQueue = DispatchQueue(label: "NetworkMonitorQueue")

    func start() {
        networkMonitor.start(queue: networkMonitorQueue)
    }
    
    func close() {
        networkMonitor.cancel()
    }

    func monitorHandler(isOffline: @escaping (Bool) -> Void) {
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // Indicate network status, e.g., back to online
                isOffline(false)
            } else {
                // Indicate network status, e.g., offline mode
                isOffline(true)
            }
        }
    }
    
    func isConnected() -> Bool {
        return networkMonitor.currentPath.status == .satisfied
    }

    func isExpensive() -> Bool {
        // Using an expensive interface, such as Cellular or a Personal Hotspot
        return networkMonitor.currentPath.isExpensive
    }

    func isConstrained() -> Bool {
        return networkMonitor.currentPath.isConstrained
    }
}
