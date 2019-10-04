//
//  DataService.swift
//  RESThub
//
//  Created by Deepak Rout on 9/28/19.
//  Copyright © 2019 Harrison. All rights reserved.
//

import Foundation

class DataSrvice {
    static let shared = DataSrvice()
    
    fileprivate let baseUrlString = "https://api.github.com"
    
    func fetchGists(completion: @escaping (Result<[Gist], Error>) -> Void)  {
        //  var baseUrl = URL(string: baseUrlString)
        // baseUrl?.appendPathComponent("/somePath")
        
        //let composedUrl = URL(string: "somePath",relativeTo: baseUrl)
        
        var componentURL = createUrlComponents(path: "/gists/public")
        
        guard let validUrl = componentURL.url else {
            print("URL creation failed")
            return
        }
        URLSession.shared.dataTask(with: validUrl) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse{
                print ("API status: \(httpResponse.statusCode)")
            }
            
            guard let validData = data, error == nil else {
                //print(" Api error: \(error!.localizedDescription)")
                completion(.failure(error!))
                return
            }
            do {
                // let json = try JSONSerialization.jsonObject(with: validData, options: [])
                let gists = try JSONDecoder().decode([Gist].self, from: validData)
                completion(.success(gists))
            }catch let seralizatioError {
                //print (seralizatioError.localizedDescription)
                completion(.failure(seralizatioError))
            }
        }.resume()
        
        //  print(baseUrl!)
        // print(composedUrl?.absoluteString ?? "Relative URL failed...")
        // print(componentURL.url!)
    }
    
    func createNewGist(completion: @escaping (Result<Any, Error>) -> Void) {
        let postComponents = createUrlComponents(path: "/gists")
        
        guard let composedURL = postComponents.url else {
            print ("URL creation failed...")
            return
        }
        
        var postRequest  = URLRequest(url: composedURL)
        postRequest.httpMethod = "POST"
        
        let authString = "garbage:garbage"
        var authStringBase64 = ""
        
        if let authData = authString.data(using: .utf8) {
            authStringBase64 = authData.base64EncodedString()
        }
        postRequest.setValue("Basic \(authStringBase64)", forHTTPHeaderField: "Authorization")
        
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let newGist = Gist(id: nil, isPublic: true, description: "A brand new gist", files: ["test_file.txt": File(content:"Hello World!")])
        
        do {
            let gistData = try JSONEncoder().encode(newGist)
            postRequest.httpBody = gistData
        } catch {
            print("Gist encoding failed!")
        }
        
        URLSession.shared.dataTask(with: postRequest){ (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            
            guard let validData = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: validData, options: [])
                completion(.success(json))
            }catch let searializationError {
                completion(.failure(searializationError))
            }
            
        }.resume()
        
    }
    
    //TODO: PUT Service call
    
    //TODO: DELETE service call
    
    func createUrlComponents(path: String) -> URLComponents {
        var componentURL = URLComponents()
        
        componentURL.scheme = "https"
        componentURL.host = "api.github.com"
        componentURL.path = path
        return componentURL
    }
}
