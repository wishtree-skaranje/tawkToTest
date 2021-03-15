//
//  GitHubUserFactory.swift
//  GitUserHandler
//
//  Created by Akshay Patil on 15/03/21.
//

import Foundation

class GitHubUserViewModelFactory {
    public static func gitHubUserViewModelFactory(_ index: Int, _ gitHubUser: GitHubUser) -> GitHubUserViewModel {
        if (!(gitHubUser.note?.isEmpty ?? true)) {
            return NoteGitHubUserViewModel(gitHubUser)
        } else if ((index+1) % 4 == 0) {
            return InvertedGitHubUserViewModel(gitHubUser)
        }
        return NoramlGitHubUserViewModel(gitHubUser)
    }
}
