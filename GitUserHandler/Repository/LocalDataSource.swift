//
//  LocalDataSource.swift
//  GitUserHandler
//
//  Created by Supriya Karanje on 13/03/21.
//

import Foundation

class LocalDataSource {
    
    func commit() {
        CoreDataStorage.shared.saveContext()
    }
    
    private func getDecoder() -> JSONDecoder{
        let decoder = JSONDecoder()
        let managedObjectContext = CoreDataStorage.shared.managedObjectContext()
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
            fatalError("Failed to retrieve managed object context Key")
        }
        decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
        return decoder
    }
    
    func createGitHubUser(_ data: Data) -> GitHubUser?{
        var gitHubUser : GitHubUser?
        let decoder = getDecoder();
        do {
            let result = try decoder.decode(GitHubUser.self, from: data)
            gitHubUser = result
            print(result)
        } catch let error {
            print("decoding error: \(error)")
        }
        return gitHubUser
    }
    
    func createGitHubUserList(_ data: Data) -> Array<GitHubUser>?{
        var gitHubUser : Array<GitHubUser>?
        let decoder = getDecoder();
        do {
            let result = try decoder.decode(Array<GitHubUser>.self, from: data)
            gitHubUser = result
            print(result)
        } catch let error {
            print("decoding error: \(error)")
        }
        return gitHubUser
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
    
    func updateGitHubUser(_ originalUser: GitHubUser, _ deatiledUser: GitHubUser) {
        if (originalUser.id == deatiledUser.id) {
            originalUser.avatar_url = deatiledUser.avatar_url
            originalUser.note = deatiledUser.note
            originalUser.blog = deatiledUser.blog
            originalUser.followers = deatiledUser.followers
            originalUser.following = deatiledUser.following
            originalUser.name = deatiledUser.name
            deleteGitHubUser(deatiledUser)
        }
    }
    
    func deleteGitHubUser(_ user: GitHubUser) {
        CoreDataStorage.shared.deleteGitHubUser(user)
    }
    
    func clearAll() {
        CoreDataStorage.shared.clearStorage(forEntity: "GitHubUser")
        commit()
    }
}
