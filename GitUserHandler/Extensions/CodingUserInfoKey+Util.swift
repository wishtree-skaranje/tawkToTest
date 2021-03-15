//
//  CodingUserInfoKey.swift
//  GitUserHandler
//
//  Created by Akshay Patil on 13/03/21.
//

import Foundation
public extension CodingUserInfoKey {
    // Helper property to retrieve the Core Data managed object context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}
