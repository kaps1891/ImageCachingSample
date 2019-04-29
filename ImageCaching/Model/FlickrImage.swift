//
//  FlickrImage.swift
//  ImageCaching
//
//  Created by Kapil on 4/28/19.
//  Copyright © 2019 Kapil. All rights reserved.
//

import Foundation

class FlickrImage: Codable {
    let photoID : String
    let farm : Int
    let server : String
    let secret : String
    
    enum CodingKeys: String, CodingKey {
        case photoID = "id"
        case farm = "farm"
        case server = "server"
        case secret = "secret"
    }
    
    
}

class FlickrOtherThings : Codable{
    let page : Int
    let perpage : Int
    let photos : [FlickrImage]
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case perpage = "perpage"
        case photos = "photo"
    }
}

class FlickrObject : Codable{
    let stat : String
    let photo : FlickrOtherThings
    enum CodingKeys: String, CodingKey {
        case stat = "stat"
        case photo = "photos"
    }
}
