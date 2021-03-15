//
//  GitHubUser+CoreDataClass.swift
//  GitUserHandler
//
//  Created by Akshay Patil on 13/03/21.
//
//

import Foundation
import CoreData

@objc(GitHubUser)
public class GitHubUser: NSManagedObject, Codable {
    @NSManaged public var login: String?
    @NSManaged public var id: Int32
    @NSManaged public var avatar_url: String?
    @NSManaged public var name: String?
    @NSManaged public var company: String?
    @NSManaged public var blog: String?
    @NSManaged public var followers: NSNumber?
    @NSManaged public var following: NSNumber?
    @NSManaged public var note: String?
    @NSManaged public var is_visited: Bool
    
    
    enum CodingKeys: String, CodingKey {
        case login
        case id
        case avatar_url
        case name
        case company
        case blog
        case followers
        case following
    }
    
    required convenience public init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "GitHubUser", in: managedObjectContext) else {
            fatalError("Failed to decode User")
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        login = try container.decode(String.self, forKey: .login)
        id = try container.decode(Int32.self, forKey: .id)
        avatar_url = try container.decode(String.self, forKey: .avatar_url)
        name = try? container.decode(String.self, forKey: .name)
        company = try? container.decode(String.self, forKey: .company)
        blog = try? container.decode(String.self, forKey: .blog)
        followers = try? container.decode(Int32.self, forKey: .followers) as NSNumber
        following = try? container.decode(Int32.self, forKey: .following) as NSNumber
    }
    
    public func encode(to encoder: Encoder) throws {
    }
}
