//
//  UberAPI.swift
//  ImageCaching
//
//  Created by Kapil on 4/28/19.
//  Copyright © 2019 Kapil. All rights reserved.
//

import UIKit

typealias JSON = Any
typealias JSONArray = [JSON]
typealias JSONObject = [String: JSON]


/// APIManager class for interacting with network layer
class UberAPI: NSObject {
    
    static let sharedInstance = UberAPI()
    
    private let sharedManager : URLSession = {
        let urlSessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.default
        return URLSession(configuration: urlSessionConfiguration, delegate: nil, delegateQueue: nil)
    }()
    
    class UrlComponents {
        let path: String
        let baseUrlString = "https://api.flickr.com/"
        let apiKey = "3e7cc266ae2b0e0d78e279ce8e361736"
        let searchQuery : String?
        var page = 0
        
        var url: URL {
            var query = [String]()
            
            
            //
            query.append("method=flickr.photos.search")
            query.append("api_key=\(apiKey)")
            query.append("format=json")
            query.append("nojsoncallback=1")
            query.append("safe_search=1")
            query.append("per_page=30")
            
            query.append("page=\(page)")
            if let searchQuery = searchQuery {
                query.append("text=\(searchQuery)")
            }
            
            guard let composedUrl = URL(string: "?" + query.joined(separator: "&"),relativeTo: NSURL(string: baseUrlString + path + "?") as URL?) else {
              //  print("Unable to build url")
                fatalError("Unable to build request url")
            }
            return composedUrl
        }
        
        init(path: String, query: String? = nil, page: Int) {
            self.path = path
            guard var query = query else{
                self.searchQuery = nil
                return
            }
            query = query.replacingOccurrences(of: " ", with: "+")
            self.searchQuery = query
            self.page = page
        }
        
    }
    
    
    /// - Parameters:
    ///   - searchText: text to be searched for
    ///   - page: pageNumber for pagination of results
    ///   - completion: completion handler for managing the response
    func fetchDataFromFlicker(withQuery searchText:String,andPage page: Int,completion: @escaping ([FlickrImage],String) ->()){
        let urlComponents = UrlComponents(path : "services/rest/", query:searchText,page:page)
        let request = URLRequest(url: (urlComponents.url))
        
        sharedManager.dataTask(with: request){ (data, response, error) in
            
            guard data != nil else{
                completion([],"Error in Data Response")
                return;
            }
            
            do {
                
                if let cError = error{
                    throw cError
                }
                
                guard let myData = data else {
                    completion([],"Error in Data Response")
                    return
                }
                
                guard let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: AnyObject],
                    let _ = resultsDictionary["stat"] as? String else {
                        return
                }
                
                let decoder = JSONDecoder()
                let item = try? decoder.decode(FlickrObject.self, from: myData)
                let photos = item?.photo.photos
                
                OperationQueue.main.addOperation({
                    completion(photos ?? [],"")
                })
                
            } catch {
                completion([],"Error ")
              //  print("JSONSerialization error:", error)
            }
            }.resume()
        
    }

}
