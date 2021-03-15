//
//  RemoteDataRepository.swift
//  GitUserHandler
//
//  Created by Akshay Patil on 13/03/21.
//

import Foundation

class RemoteDataSource {
    func getGitHubUsers(_ since: Int, success: @escaping (Array<GitHubUser>) -> Void, error : @escaping () -> Void) {
        let githubUserURL = URL(string: "https://api.github.com/users?since=\(since)")!
        
        let githubUserListResource = Resource<Array<GitHubUser>>(url: githubUserURL) { data in
            var gitHubUser : Array<GitHubUser>?
            let decoder = JSONDecoder()
            let managedObjectContext = CoreDataStorage.shared.managedObjectContext()
            guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                fatalError("Failed to retrieve managed object context Key")
            }
            decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
            do {
                let result = try decoder.decode([GitHubUser].self, from: data)
                gitHubUser = result
                print(result)
            } catch let error {
                print("decoding error: \(error)")
            }
            return gitHubUser!
        }
        DispatchQueue(label: "userapi.serial.queue").async {
            Webservice().load(resource: githubUserListResource) { result in
                if let gitHubUser = result {
                    DispatchQueue.main.async {
                        success(gitHubUser)
                    }
                }
            }
        }
    }
    
    func getGitHubUser(_ userName: String, success: @escaping (GitHubUser) -> Void, error : @escaping () -> Void) {
        let githubUserURL = URL(string: "https://api.github.com/users/\(userName)")!
        
        let githubUserListResource = Resource<GitHubUser>(url: githubUserURL) { data in
            var gitHubUser : GitHubUser?
            let decoder = JSONDecoder()
            let managedObjectContext = CoreDataStorage.shared.managedObjectContext()
            guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                fatalError("Failed to retrieve managed object context Key")
            }
            decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
            do {
                let result = try decoder.decode(GitHubUser.self, from: data)
                gitHubUser = result
                print(result)
            } catch let error {
                print("decoding error: \(error)")
            }
//            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
//            print(paths[0])
            return gitHubUser!
        }
        DispatchQueue(label: "userapi.serial.queue").async {
            Webservice().load(resource: githubUserListResource) { result in
                if let gitHubUser = result {
                    DispatchQueue.main.async {
                        success(gitHubUser)
                    }
                }
            }
        }
    }
    
    func loadImage(urlString: String, userName: String, completionHandler: @escaping (_ urlString: String, _ userName: String ,_ data: Data?) -> ()) {
        DispatchQueue(label: "userapi.serial.queue").sync {
            Webservice().loadImage(urlString: urlString, userName: userName) { (url, username, data) in
                DispatchQueue.main.async {
                    completionHandler(url, username ,data)
                }
            }
        }
    }
}
