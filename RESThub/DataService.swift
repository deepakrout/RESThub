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
    
    let customSession: URLSession = {
        let customeConfig = URLSessionConfiguration.default
       // let backgroundConfig = URLSessionConfiguration.background(withIdentifier: "")
        customeConfig.networkServiceType = .video
        customeConfig.allowsCellularAccess = true
        
        
        return URLSession(configuration: customeConfig)
    }()
    
    func fetchGists(completion: @escaping (Result<[Gist], Error>) -> Void)  {
        //  var baseUrl = URL(string: baseUrlString)
        // baseUrl?.appendPathComponent("/somePath")
        
        //let composedUrl = URL(string: "somePath",relativeTo: baseUrl)
        
        let componentURL = createUrlComponents(path: "/gists/public")
        
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
        
  
    }
    
    func createNewGist(completion: @escaping (Result<Any, Error>) -> Void) {
        let postComponents = createUrlComponents(path: "/gists")
        
        guard let composedURL = postComponents.url else {
            print ("URL creation failed...")
            return
        }
        
        var postRequest  = URLRequest(url: composedURL)
        postRequest.httpMethod = "POST"
        
        //Create authentication string
        let authStringBase64 = createAuthCredentials()
        
        postRequest.setValue("Basic \(authStringBase64)", forHTTPHeaderField: "Authorization")
        
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        postRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        //Create new Gist body
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
    
    //Star Unstar method. 10/09/2019
    func starUnstarGist(id: String, star:Bool, completion: @escaping (Bool)-> Void){
        
        let starComponent = createUrlComponents(path: "/gists/\(id)/star")
        
        guard let composeURL = starComponent.url else {
            print("Componenet Composition failed...")
            return
        }
        
        var starRequest = URLRequest(url: composeURL)
        
        starRequest.httpMethod = star == true ? "PUT" : "DELETE"
        
        starRequest.setValue("0", forHTTPHeaderField: "Content-Length")
        starRequest.setValue("Basic \(createAuthCredentials())", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: starRequest) { (data, response, error) in
            
            if let httpResponse  = response as? HTTPURLResponse {
                print ("Staus code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 204 {
                    completion(true)
                }
                else {
                    completion(false)
                }
            }
            
        }.resume()
        
    }
    
    func createAuthCredentials() -> String {
        let authString = "garbage:garbage"
        var authStringBase64 = ""
        
        if let authData = authString.data(using: .utf8) {
            authStringBase64 = authData.base64EncodedString()
        }
        return authStringBase64
    }
    
    func createUrlComponents(path: String) -> URLComponents {
        var componentURL = URLComponents()
        
        componentURL.scheme = "https"
        componentURL.host = "api.github.com"
        componentURL.path = path
        return componentURL
    }
}
