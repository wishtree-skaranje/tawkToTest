//
//  GitUserHandlerTests.swift
//  GitUserHandlerTests
//
//  Created by Supriya Karanje on 13/03/21.
//

import XCTest
@testable import GitUserHandler

class GitUserHandlerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        LocalDataSource().clearAll()
    }

    func testGitUser_create_new_user_by_json_data() throws {
        let data : Data = "{\n    \"login\": \"defunkt\",\n    \"id\": 2,\n    \"node_id\": \"MDQ6VXNlcjI=\",\n    \"avatar_url\": \"https://avatars.githubusercontent.com/u/2?v=4\",\n    \"gravatar_id\": \"\",\n    \"url\": \"https://api.github.com/users/defunkt\",\n    \"html_url\": \"https://github.com/defunkt\",\n    \"followers_url\": \"https://api.github.com/users/defunkt/followers\",\n    \"following_url\": \"https://api.github.com/users/defunkt/following{/other_user}\",\n    \"gists_url\": \"https://api.github.com/users/defunkt/gists{/gist_id}\",\n    \"starred_url\": \"https://api.github.com/users/defunkt/starred{/owner}{/repo}\",\n    \"subscriptions_url\": \"https://api.github.com/users/defunkt/subscriptions\",\n    \"organizations_url\": \"https://api.github.com/users/defunkt/orgs\",\n    \"repos_url\": \"https://api.github.com/users/defunkt/repos\",\n    \"events_url\": \"https://api.github.com/users/defunkt/events{/privacy}\",\n    \"received_events_url\": \"https://api.github.com/users/defunkt/received_events\",\n    \"type\": \"User\",\n    \"site_admin\": false\n  }".data(using: .utf8)!
        
        
        let gitUser = LocalDataSource().createGitHubUser(data)
            
        XCTAssertNotNil(gitUser, "nil reference after GitUser creation")
        LocalDataSource().commit()
        
        let fetchedGitUser = LocalDataSource().getGitHubUser(id: "2")
        XCTAssertEqual(fetchedGitUser?.id, 2, "Wrong id, id should be 2")
        XCTAssertEqual(fetchedGitUser?.login, "defunkt", "Wrong login, login should be defunkt")
        XCTAssertEqual(fetchedGitUser?.avatar_url, "https://avatars.githubusercontent.com/u/2?v=4", "Wrong avatar_url, avatar_url should be https://avatars.githubusercontent.com/u/2?v=4")
    }
    
    func testGitUser_update_user_note() throws {
        let data : Data = "{\n    \"login\": \"defunkt\",\n    \"id\": 2,\n    \"node_id\": \"MDQ6VXNlcjI=\",\n    \"avatar_url\": \"https://avatars.githubusercontent.com/u/2?v=4\",\n    \"gravatar_id\": \"\",\n    \"url\": \"https://api.github.com/users/defunkt\",\n    \"html_url\": \"https://github.com/defunkt\",\n    \"followers_url\": \"https://api.github.com/users/defunkt/followers\",\n    \"following_url\": \"https://api.github.com/users/defunkt/following{/other_user}\",\n    \"gists_url\": \"https://api.github.com/users/defunkt/gists{/gist_id}\",\n    \"starred_url\": \"https://api.github.com/users/defunkt/starred{/owner}{/repo}\",\n    \"subscriptions_url\": \"https://api.github.com/users/defunkt/subscriptions\",\n    \"organizations_url\": \"https://api.github.com/users/defunkt/orgs\",\n    \"repos_url\": \"https://api.github.com/users/defunkt/repos\",\n    \"events_url\": \"https://api.github.com/users/defunkt/events{/privacy}\",\n    \"received_events_url\": \"https://api.github.com/users/defunkt/received_events\",\n    \"type\": \"User\",\n    \"site_admin\": false\n  }".data(using: .utf8)!
        
        let localDataSource = LocalDataSource()
        let gitUser = localDataSource.createGitHubUser(data)
            
        XCTAssertNotNil(gitUser, "nil reference after GitUser creation")
        localDataSource.commit()
        
        let gitUserViewModel = GitHubUserViewModel(2)
        gitUserViewModel.saveNote(note: "New Note")
        
        let fetchedGitUser = LocalDataSource().getGitHubUser(id: "2")
        
        XCTAssertEqual(fetchedGitUser?.id, 2, "Wrong id, id should be 2")
        XCTAssertEqual(fetchedGitUser?.note, "New Note", "Wrong note, note should be New Note")
    }
    
    
    func testGitUser_update_model_with_detailed_json_data() throws {
        
        let localDataSource = LocalDataSource()
        let data : Data = "{\n    \"login\": \"defunkt\",\n    \"id\": 2,\n    \"node_id\": \"MDQ6VXNlcjI=\",\n    \"avatar_url\": \"https://avatars.githubusercontent.com/u/2?v=4\",\n    \"gravatar_id\": \"\",\n    \"url\": \"https://api.github.com/users/defunkt\",\n    \"html_url\": \"https://github.com/defunkt\",\n    \"followers_url\": \"https://api.github.com/users/defunkt/followers\",\n    \"following_url\": \"https://api.github.com/users/defunkt/following{/other_user}\",\n    \"gists_url\": \"https://api.github.com/users/defunkt/gists{/gist_id}\",\n    \"starred_url\": \"https://api.github.com/users/defunkt/starred{/owner}{/repo}\",\n    \"subscriptions_url\": \"https://api.github.com/users/defunkt/subscriptions\",\n    \"organizations_url\": \"https://api.github.com/users/defunkt/orgs\",\n    \"repos_url\": \"https://api.github.com/users/defunkt/repos\",\n    \"events_url\": \"https://api.github.com/users/defunkt/events{/privacy}\",\n    \"received_events_url\": \"https://api.github.com/users/defunkt/received_events\",\n    \"type\": \"User\",\n    \"site_admin\": false\n  }".data(using: .utf8)!
        
        
        let gitUser = localDataSource.createGitHubUser(data)
            
        XCTAssertNotNil(gitUser, "nil reference after GitUser creation")
        localDataSource.commit()
        
        
        let detailedJSON : Data = "{\n  \"login\": \"defunkt\",\n  \"id\": 2,\n  \"node_id\": \"MDQ6VXNlcjI=\",\n  \"avatar_url\": \"https://avatars.githubusercontent.com/u/2?v=4\",\n  \"gravatar_id\": \"\",\n  \"url\": \"https://api.github.com/users/defunkt\",\n  \"html_url\": \"https://github.com/defunkt\",\n  \"followers_url\": \"https://api.github.com/users/defunkt/followers\",\n  \"following_url\": \"https://api.github.com/users/defunkt/following{/other_user}\",\n  \"gists_url\": \"https://api.github.com/users/defunkt/gists{/gist_id}\",\n  \"starred_url\": \"https://api.github.com/users/defunkt/starred{/owner}{/repo}\",\n  \"subscriptions_url\": \"https://api.github.com/users/defunkt/subscriptions\",\n  \"organizations_url\": \"https://api.github.com/users/defunkt/orgs\",\n  \"repos_url\": \"https://api.github.com/users/defunkt/repos\",\n  \"events_url\": \"https://api.github.com/users/defunkt/events{/privacy}\",\n  \"received_events_url\": \"https://api.github.com/users/defunkt/received_events\",\n  \"type\": \"User\",\n  \"site_admin\": false,\n  \"name\": \"Chris Wanstrath\",\n  \"company\": null,\n  \"blog\": \"http://chriswanstrath.com/\",\n  \"location\": null,\n  \"email\": null,\n  \"hireable\": null,\n  \"bio\": \"\",\n  \"twitter_username\": null,\n  \"public_repos\": 107,\n  \"public_gists\": 273,\n  \"followers\": 21158,\n  \"following\": 210,\n  \"created_at\": \"2007-10-20T05:24:19Z\",\n  \"updated_at\": \"2019-11-01T21:56:00Z\"\n}".data(using: .utf8)!
        
        let detailedGitUser = localDataSource.createGitHubUser(detailedJSON)
        XCTAssertNotNil(detailedGitUser, "nil reference after GitUser creation")
        
        localDataSource.updateGitHubUser(gitUser!, detailedGitUser!)
        localDataSource.commit()
        
        XCTAssertNotNil(gitUser, "nil reference after GitUser update")
        
        XCTAssertEqual(gitUser?.id, 2, "Wrong id, id should be 2")
        XCTAssertEqual(gitUser?.login, "defunkt", "Wrong login, login should be defunkt")
        XCTAssertEqual(gitUser?.avatar_url, "https://avatars.githubusercontent.com/u/2?v=4", "Wrong avatar_url, avatar_url should be https://avatars.githubusercontent.com/u/2?v=4")
        XCTAssertEqual(gitUser?.following, 210, "Wrong following, following should be 210")
        XCTAssertEqual(gitUser?.followers, 21158, "Wrong followers, followers should be 21158")
        XCTAssertEqual(gitUser?.blog, "http://chriswanstrath.com/", "Wrong blog, blog should be http://chriswanstrath.com/")
    }
    
}
