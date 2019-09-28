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
        
        var componentURL = URLComponents()
        
        componentURL.scheme = "https"
        componentURL.host = "api.github.com"
        componentURL.path = "/gists/public"
        
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
}
