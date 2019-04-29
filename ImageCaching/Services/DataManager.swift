//
//  DataManager.swift
//  ImageCaching
//
//  Created by Kapil on 4/28/19.
//  Copyright © 2019 Kapil. All rights reserved.
//

import UIKit


/// Singleton class to manage data either from the API or from the database. API in our case
class DataManager: NSObject {
    
    static let sharedInstance : DataManager = {
        var manager = DataManager()
        return manager
    }()
    
    
   
    /// - Parameters:
    ///   - searchText: search string entered in the search bar
    ///   - page: pagenumber for pagination of results
    ///   - callback: completion handler for managing the response
    func getData(withSearchQuery searchText:String,andPage page:Int,callback: @escaping (_ result:[FlickrImage],_ str:String)->()){
        UberAPI.sharedInstance.fetchDataFromFlicker(withQuery: searchText, andPage: page) { imagesArray,msg  in
            callback(imagesArray,msg)
        }
        
    }

}
