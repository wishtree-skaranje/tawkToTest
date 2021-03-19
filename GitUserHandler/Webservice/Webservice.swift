//
//  Webservice.swift
//  GitUserHandler
//
//  Created by Supriya Karanje on 13/03/21.
//

import Foundation

struct Resource<T> {
    let url: URL
    let parse: (Data) -> T?
}

final class Webservice {
    static let shared = Webservice()
    let urlSessionConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 1
        return configuration
    }()
    
    private let operationQueue : OperationQueue = {
        let oQueue = OperationQueue()
        oQueue.maxConcurrentOperationCount = 1
        return oQueue
    }()
    
    func load<T>(resource: Resource<T>, completion: @escaping (T?) -> ()) {
        let dataTask = URLSession(configuration: urlSessionConfiguration, delegate: nil, delegateQueue: operationQueue).dataTask(with: resource.url) { data, response, error in
            if let data = data {
                completion(resource.parse(data))
            } else {
                completion(nil)
            }
            CustomQueue.shared.taskExecutionCompleted()
            //        }.resume()
        }
        CustomQueue.shared.addDataTask(dataTask)
    }
    
    func loadImage(urlString: String, userName: String, completionHandler: @escaping (_ urlString: String, _ userName: String ,_ data: Data?) -> ())  {
        do {
            let documentFolderURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = documentFolderURL.appendingPathComponent(userName)
            if (FileManager.default.fileExists(atPath: fileURL.path)) {
                let data = try Data(contentsOf: fileURL)
                completionHandler(urlString, userName, data)
                print("image Success: from disk cache \(userName)")
                return
            }
        } catch  {
            print("error reading file \(userName) : \(error)")
        }
        let url = URL(string: urlString)!
        print("\(urlString) loading")
        let dataTask = URLSession(configuration: urlSessionConfiguration, delegate: nil, delegateQueue: operationQueue).dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error!)
                CustomQueue.shared.taskExecutionCompleted()
                return
            }
            
            do {
                let documentFolderURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = documentFolderURL.appendingPathComponent(userName)
                try data!.write(to: fileURL)
                
            } catch  {
                print("error writing file \(userName) : \(error)")
            }
            completionHandler(urlString, userName, data)
            CustomQueue.shared.taskExecutionCompleted()
            //        }.resume()
        }
        CustomQueue.shared.addDataTask(dataTask)
    }
}

class CustomQueue {
    static let shared = CustomQueue()
    private var taskQueue = Array<URLSessionDataTask>()
    private var currentTask : URLSessionDataTask?
    func addDataTask(_ dataTask: URLSessionDataTask) {
        taskQueue.append(dataTask)
        notifyResumeTask()
    }

    func taskExecutionCompleted() {
        currentTask = nil
        notifyResumeTask()
    }

    func notifyResumeTask() {
        if (currentTask == nil && taskQueue.count > 0) {
            currentTask = taskQueue[0]
            currentTask?.resume()
            taskQueue.remove(at: 0)
        }
    }
}
