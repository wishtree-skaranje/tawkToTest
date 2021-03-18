//
//  GitHubUserListViewModel.swift
//  GitUserHandler
//
//  Created by Supriya Karanje on 13/03/21.
//

import Foundation

protocol GitHubUserListViewModelProtocol {
    func listLoaded()
    func loadingInitaited()
    func showErrorUI(errorText: String, imageName: String)
    func hideErrorUI()
    func showErrorUIPopover(errorText: String)
}

class GitHubUserListViewModel{
    private var gitHubUserList : Array<GitHubUserViewModel>?
    private var gitHubUserVMDelegate: GitHubUserListViewModelProtocol?
    private var searchText : String = ""
    private var exponentialBackoffTime = 5
    public var isSearchActive: Bool {
        get {
            return !searchText.isEmpty
        }
    }
    
    init() {
        NetworkManager.sharedInstance.addNetworkStateObserver(networkOserver: self)
    }
    
    private (set) var isLoading: Bool = false

    func setProtocol(_ ghu: GitHubUserListViewModelProtocol) {
        self.gitHubUserVMDelegate = ghu
    }
    
    func numberOfRows() -> Int{
        if isLoading {
            return ((gitHubUserList?.count != nil) ? gitHubUserList!.count : 0) + 1
        } else {
            return ((gitHubUserList?.count != nil) ? gitHubUserList!.count : 0)
        }
    }
    
    func gitHubUserViewModelAt(index: Int) -> GitHubUserViewModel? {
        if gitHubUserList?.count ?? 0 > index, let gitHubUserViewModel = gitHubUserList?[index] {
            return gitHubUserViewModel
        } else if (isLoading) {
            return nil
        }
        fatalError("No GitHubUserViewModel found at index \(index)")
    }
    
    func notifyAPIError() {
        gitHubUserVMDelegate?.showErrorUIPopover(errorText: "Loading failed, reloading will starts in \(exponentialBackoffTime) seconds")
        let dispatchAfter = DispatchTimeInterval.seconds(exponentialBackoffTime)
        isLoading = false
        DispatchQueue.main.asyncAfter(deadline: .now() + dispatchAfter) {
            self.exponentialBackoffTime = self.exponentialBackoffTime * 2
            self.reloadAfterError()
        }
    }
    
    func reloadAfterError() {
        self.loadNextPage()
    }
}

extension GitHubUserListViewModel {
    func searchUpdated(text: String) {
        if (text == searchText){
            return
        }
        searchText = text
        if (isSearchActive) {
            let localDataSource = LocalDataSource()
            let users = localDataSource.searchGitHubUsers(text: searchText)
            self.gitHubUserList = users.enumerated().compactMap { (index, gitHubUser) -> GitHubUserViewModel? in
                return GitHubUserViewModelFactory.gitHubUserViewModelFactory(index, gitHubUser)
            }
            self.gitHubUserVMDelegate?.listLoaded()
        } else {
            load()
        }
    }
}

extension GitHubUserListViewModel {
    func load() {
        self.gitHubUserVMDelegate?.loadingInitaited()
        if (isLoading || isSearchActive) {
            return
        }
        isLoading = true
        let localDataSource = LocalDataSource()
        localDataSource.getGitHubUsers(0) { (users) in
            if (users.count > 0) {
                let userVMList = users.enumerated().compactMap { (index, gitHubUser) -> GitHubUserViewModel? in
                    return GitHubUserViewModelFactory.gitHubUserViewModelFactory(index, gitHubUser)
                }
                self.isLoading = false
                self.gitHubUserList = userVMList
                self.gitHubUserVMDelegate?.listLoaded()
            } else if (NetworkManager.sharedInstance.isOnline()) {
                let remoteDataSource = RemoteDataSource()
                remoteDataSource.getGitHubUsers(0, success:  { (result) in
                    let userVMList = result.enumerated().compactMap { (index, gitHubUser) -> GitHubUserViewModel? in
                        return GitHubUserViewModelFactory.gitHubUserViewModelFactory(index, gitHubUser)
                    }
                    CoreDataStorage.shared.saveContext()
                    self.isLoading = false
                    self.gitHubUserList = userVMList
                    self.gitHubUserVMDelegate?.listLoaded()
                }, error: {
                    self.notifyAPIError()
                })
            } else {
                self.gitHubUserVMDelegate?.showErrorUI(errorText: "No internet connection", imageName: "no_internet_connection")
            }
        }
    }
    
    func loadNextPage() {
        self.gitHubUserVMDelegate?.loadingInitaited()
        if (self.isLoading || isSearchActive) {
            return
        }
        var lastId = 0
        if ((gitHubUserList?.count) != nil) {
            lastId = Int(gitHubUserList?[gitHubUserList!.count - 1].gitHubUser.id ?? 0)
        }
        self.isLoading = true
        self.gitHubUserVMDelegate?.listLoaded()
        let remoteDataSource = RemoteDataSource()
        remoteDataSource.getGitHubUsers(lastId, success: { (result) in
            let userVMList = result.enumerated().compactMap { (index, gitHubUser) -> GitHubUserViewModel? in
                return GitHubUserViewModelFactory.gitHubUserViewModelFactory(index, gitHubUser)
            }
            CoreDataStorage.shared.saveContext()
            self.isLoading = false
            self.gitHubUserList?.append(contentsOf: userVMList)
            self.gitHubUserVMDelegate?.listLoaded()
        }, error: {
            self.notifyAPIError()
        })
    }
}

extension GitHubUserListViewModel: NetworkStateObserver {
    func networkStateChanged(online: Bool) {
        if (online && (gitHubUserList?.count ?? 0) == 0) {
            self.gitHubUserVMDelegate?.hideErrorUI()
            load()
        }
    }
}
