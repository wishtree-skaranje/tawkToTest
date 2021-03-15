//
//  GitHubUserViewModel.swift
//  GitUserHandler
//
//  Created by Supriya Karanje on 13/03/21.
//

import Foundation

protocol GitHubUserViewModelProtocol {
    func userFound()
    func userSaved()
    
    func userLoadingInitaited()
    func showErrorUIPopover(errorText: String)
    
    func showNoInternetConenctionUI()
    func hideNoInternetConenction()
}

protocol ImageLoaderProtocol {
    func imageFound(_ urlString: String ,_ data: Data?)
}

open class GitHubUserViewModel {
    public var gitHubUser : GitHubUser
    private (set) var gitHubUserVMDelegate : GitHubUserViewModelProtocol?
    private (set) var imageLoaderDelegate : ImageLoaderProtocol?
    private let localDataSource = LocalDataSource()
    private var isLoading = false
    private var exponentialBackoffTime = 5
    init(_ ghu : GitHubUser) {
        self.gitHubUser = ghu
    }
    
    init(_ withId : Int32?) {
        self.gitHubUser = localDataSource.getGitHubUser(id: String(withId!))!
    }
    
    func cellIdentifier() -> String{
        fatalError("Invalid cell identfier")
    }
    
    func setGitHubUserViewModelDelegate(_ delegate: ImageLoaderProtocol) {
        imageLoaderDelegate = delegate
    }
    
    func setGitHubUserViewModelDelegate(_ delegate: GitHubUserViewModelProtocol) {
        gitHubUserVMDelegate = delegate
    }
    
    func setup() {
        NetworkManager.sharedInstance.addNetworkStateObserver(networkOserver: self)
    }
    
    func cleanup() {
        NetworkManager.sharedInstance.removeNetworkStateObserver(networkObserver: self)
    }
    
    func load() {
        if (isLoading) {
            return
        }
        isLoading = true
        self.gitHubUserVMDelegate?.userLoadingInitaited()
        if (self.gitHubUser.is_visited) {
            isLoading = false
            self.gitHubUserVMDelegate?.userFound()
        } else if (NetworkManager.sharedInstance.isOnline()) {
            let remoteDataSource = RemoteDataSource()
            remoteDataSource.getGitHubUser(self.gitHubUser.login!) { (gitHubUser) in
                self.localDataSource.updateGitHubUser(self.gitHubUser, gitHubUser)
                self.gitHubUser.is_visited = true
                self.localDataSource.commit()
                self.isLoading = false
                self.gitHubUserVMDelegate?.userFound()
            } error: {
                self.notifyAPIError()
            }
        } else {
            self.gitHubUserVMDelegate?.showNoInternetConenctionUI()
        }
    }
    
    func saveNote(note: String) {
        self.gitHubUser.note = note
        self.localDataSource.commit()
        self.gitHubUserVMDelegate?.userSaved()
    }
    
    func loadImage(urlString: String, completionHandler: @escaping (_ urlString: String, _ userName: String ,_ data: Data?) -> ()) {
        let remoteDataSource = RemoteDataSource()
        remoteDataSource.loadImage(urlString: urlString, userName: self.gitHubUser.login!) { (url, userName, imageData) in
            completionHandler(url, userName, imageData)
        }
    }
    
    func loadImage(urlString: String) {
        let remoteDataSource = RemoteDataSource()
        remoteDataSource.loadImage(urlString: urlString, userName: self.gitHubUser.login!) { (url, userName,imageData) in
            self.imageLoaderDelegate?.imageFound(url, imageData)
        }
    }
    
    func notifyAPIError() {
        gitHubUserVMDelegate?.showErrorUIPopover(errorText: "Loading failed, reloading will starts in \(exponentialBackoffTime) seconds")
        isLoading = false
        let dispatchAfter = DispatchTimeInterval.seconds(exponentialBackoffTime)
        DispatchQueue.main.asyncAfter(deadline: .now() + dispatchAfter) {
            self.exponentialBackoffTime = self.exponentialBackoffTime * 2
            self.reloadAfterError()
        }
    }
    
    func reloadAfterError() {
        self.load()
    }
}

extension GitHubUserViewModel: NetworkStateObserver {
    func networkStateChanged(online: Bool) {
        if (online && !(self.gitHubUser.is_visited)) {
            load()
        }
    }
}

class NoramlGitHubUserViewModel : GitHubUserViewModel {
    override func cellIdentifier() -> String {
        return Constants.normalCellIdentifier
    }
}

class NoteGitHubUserViewModel : GitHubUserViewModel {
    override func cellIdentifier() -> String {
        return Constants.noteCellIdentifier
    }
}

class InvertedGitHubUserViewModel : GitHubUserViewModel {
    override func cellIdentifier() -> String {
        return Constants.invertedCellIdentifier
    }
}
