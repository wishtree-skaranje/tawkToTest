//
//  NetworkStateManager.swift
//  GitUserHandler
//
//  Created by Supriya Karanje on 15/03/21.
//

import Foundation

protocol NetworkStateObserver {
    func networkStateChanged(online: Bool)
}

class NetworkManager: NSObject {

    var reachability: Reachability!
    private (set) var networkStateObservers = Array<NetworkStateObserver>()
    public static let sharedInstance: NetworkManager = { return NetworkManager() }()
    
    override init() {
        super.init()

        do {
            try reachability = Reachability()
        } catch {
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func addNetworkStateObserver(networkOserver: NetworkStateObserver) {
        networkStateObservers.append(networkOserver)
    }
    
    func removeNetworkStateObserver(networkObserver: NetworkStateObserver) {
        if (networkStateObservers.count <= 2) {
            networkStateObservers.remove(at: 1)
        }
    }
    
    func isOnline() -> Bool {
        return (NetworkManager.sharedInstance.reachability).connection != .unavailable
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        let online = isOnline()
        DispatchQueue.main.async {
            self.networkStateObservers.forEach { (observer) in
                observer.networkStateChanged(online: online)
            }
        }
    }
    
    static func stopNotifier() -> Void {
        do {
            try (NetworkManager.sharedInstance.reachability).stopNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }

    static func isReachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection != .unavailable {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    static func isUnreachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .unavailable {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    static func isReachableViaWWAN(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .cellular {
            completed(NetworkManager.sharedInstance)
        }
    }

    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .wifi {
            completed(NetworkManager.sharedInstance)
        }
    }
}
