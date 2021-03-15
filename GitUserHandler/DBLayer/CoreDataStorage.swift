//
//  CoreDataStorage.swift
//  GitUserHandler
//
//  Created by Akshay Patil on 13/03/21.
//

import Foundation
import CoreData

class CoreDataStorage: NSObject {
    static let shared = CoreDataStorage()
    private override init() {
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "GitUserHandler")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func managedObjectContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support

    func saveContext () {
//        persistentContainer.performBackgroundTask { (context) in
        let context = persistentContainer.viewContext
        context.perform {
                if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
    }
    
    func fetchGitHubUsers(_ success: @escaping (Array<GitHubUser>?) -> Void) {
        let context = persistentContainer.viewContext
        context.perform {
            var users : Array<GitHubUser>?
            let fetchRequest = GitHubUser.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
            fetchRequest.returnsObjectsAsFaults = false
            users = try? (context.fetch(fetchRequest) as! Array<GitHubUser>)
            success(users)
        }
    }
    
    func fetchGitHubUsers(_ text: String) -> Array<GitHubUser>?{
        let context = persistentContainer.viewContext
        var users : Array<GitHubUser>?
        let fetchRequest = GitHubUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: " login CONTAINS[c] %@ ", text)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
//        fetchRequest.returnsObjectsAsFaults = false
        users = try? (context.fetch(fetchRequest) as! Array<GitHubUser>)
        return users
    }
    
    func fetchGitHubUser(_ id: String) -> GitHubUser?{
        let context = persistentContainer.viewContext
        var user : GitHubUser?
        let fetchRequest = GitHubUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: " id == %@ ", id)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
//        fetchRequest.returnsObjectsAsFaults = false
        let users = try! (context.fetch(fetchRequest) as! [GitHubUser])
        if (users.count > 0) {
            user = users[0]
        }
        return user
    }
    
    func deleteGitHubUser(_ user: GitHubUser) {
        let context = persistentContainer.viewContext
        context.perform {
            context.delete(user)
        }
    }
    
//MARK : Delete this
    func clearStorage(forEntity entity: String) {
        let isInMemoryStore = persistentContainer.persistentStoreDescriptions.reduce(false) {
            return $0 ? true : $1.type == NSInMemoryStoreType
        }

        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        // NSBatchDeleteRequest is not supported for in-memory stores
        if isInMemoryStore {
            do {
                let entities = try managedObjectContext.fetch(fetchRequest)
                for entity in entities {
                    managedObjectContext.delete(entity as! NSManagedObject)
                }
            } catch let error as NSError {
                print(error)
            }
        } else {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObjectContext.execute(batchDeleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
    }
}