//
//  LocalDataSource.swift
//  GitUserHandler
//
//  Created by Akshay Patil on 13/03/21.
//

import Foundation


class LocalDataSource {
    
    func commit() {
        CoreDataStorage.shared.saveContext()
    }
    
    func getGitHubUsers(_ since: Int, success: @escaping (Array<GitHubUser>) -> Void) {
        CoreDataStorage.shared.fetchGitHubUsers { (users) in
            if let users = users {
                success(users)
            } else {
                success([])
            }
        }
    }
    
    func searchGitHubUsers(text: String) -> Array<GitHubUser> {
        if let users = CoreDataStorage.shared.fetchGitHubUsers(text) {
            return users
        } else {
            return []
        }
    }
    
    func getGitHubUser(id: String) -> GitHubUser? {
        return CoreDataStorage.shared.fetchGitHubUser(id)
    }
    
    func deleteGitHubUser(_ user: GitHubUser) {
        CoreDataStorage.shared.deleteGitHubUser(user)
    }
}
