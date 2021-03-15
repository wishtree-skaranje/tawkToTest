//
//  Webservice.swift
//  GitUserHandler
//
//  Created by Akshay Patil on 13/03/21.
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
    
    
    func load<T>(resource: Resource<T>, completion: @escaping (T?) -> ()) {
        URLSession(configuration: urlSessionConfiguration).dataTask(with: resource.url) { data, response, error in
            if let data = data {
                completion(resource.parse(data))
            } else {
                completion(nil)
            }
            
        }.resume()
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
        URLSession(configuration: urlSessionConfiguration).dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print(error!)
                return
            }
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                print("Success: \(statusCode)")
            }
            
            do {
                let documentFolderURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileURL = documentFolderURL.appendingPathComponent(userName)
                try data!.write(to: fileURL)
                
            } catch  {
                print("error writing file \(userName) : \(error)")
            }
            completionHandler(urlString, userName, data)
        }.resume()
    }
}
