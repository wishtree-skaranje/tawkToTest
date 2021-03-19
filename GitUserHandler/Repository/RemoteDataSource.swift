//
//  RemoteDataRepository.swift
//  GitUserHandler
//
//  Created by Supriya Karanje on 13/03/21.
//

import Foundation

class RemoteDataSource {
    func getGitHubUsers(_ since: Int, success: @escaping (Array<GitHubUser>) -> Void, error : @escaping () -> Void) {
        let githubUserURL = URL(string: "https://api.github.com/users?since=\(since)")!
        
        let githubUserListResource = Resource<Array<GitHubUser>>(url: githubUserURL) { data in
            return LocalDataSource().createGitHubUserList(data)
        }
        DispatchQueue(label: "userapi.serial.queue").async {
            Webservice.shared.load(resource: githubUserListResource) { result in
                if let gitHubUser = result {
                    DispatchQueue.main.async {
                        success(gitHubUser)
                    }
                } else {
                    DispatchQueue.main.async {
                        error()
                    }
                }
            }
        }
    }
    
    func getGitHubUser(_ userName: String, success: @escaping (GitHubUser) -> Void, error : @escaping () -> Void) {
        let githubUserURL = URL(string: "https://api.github.com/users/\(userName)")!
        
        let githubUserListResource = Resource<GitHubUser>(url: githubUserURL) { data in
            return LocalDataSource().createGitHubUser(data)
        }
        DispatchQueue(label: "userapi.serial.queue").async {
            Webservice.shared.load(resource: githubUserListResource) { result in
                if let gitHubUser = result {
                    DispatchQueue.main.async {
                        success(gitHubUser)
                    }
                } else {
                    DispatchQueue.main.async {
                        error()
                    }
                }
            }
        }
    }
    
    func loadImage(urlString: String, userName: String, completionHandler: @escaping (_ urlString: String, _ userName: String ,_ data: Data?) -> ()) {
        DispatchQueue(label: "userapi.serial.queue").sync {
            Webservice.shared.loadImage(urlString: urlString, userName: userName) { (url, username, data) in
                DispatchQueue.main.async {
                    completionHandler(url, username ,data)
                }
            }
        }
    }
}
