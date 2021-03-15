//
//  GitHubUserViewModel.swift
//  GitUserHandler
//
//  Created by Akshay Patil on 13/03/21.
//

import Foundation

open class GitHubUserViewModel {
    public var gitHubUser : GitHubUser
    private (set) var gitHubUserVMDelegate : GitHubUserViewModelProtocol?
    private (set) var imageLoaderDelegate : ImageLoaderProtocol?
    private let localDataSource = LocalDataSource()
    init(_ ghu : GitHubUser) {
        self.gitHubUser = ghu
    }
    
    init(_ withId : Int32?) {
        self.gitHubUser = localDataSource.getGitHubUser(id: String(withId ?? 0))!
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
    
    func load() {
        if (self.gitHubUser.is_visited) {
            self.gitHubUserVMDelegate?.userFound()
        } else {
            DispatchQueue.global(qos: .background).async {
                let remoteDataSource = RemoteDataSource()
                remoteDataSource.getGitHubUser(self.gitHubUser.login ?? "") { (gitHubUser) in
                    DispatchQueue.main.async {
                        gitHubUser.is_visited = true
                        self.localDataSource.deleteGitHubUser(self.gitHubUser)
                        self.gitHubUser = gitHubUser
                        self.localDataSource.commit()
                        self.gitHubUserVMDelegate?.userFound()
                    }
                } error: {
                    
                }
                
            }
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
}

protocol GitHubUserViewModelProtocol {
    func userFound()
    func userSaved()
}

protocol ImageLoaderProtocol {
    func imageFound(_ urlString: String ,_ data: Data?)
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
