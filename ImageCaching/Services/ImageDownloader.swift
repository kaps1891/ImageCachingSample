//
//  ImageDownloader.swift
//  ImageCaching
//
//  Created by Kapil on 4/28/19.
//  Copyright © 2019 Kapil. All rights reserved.
//

import UIKit


typealias ImageDownloadHandler = (_ image : UIImage?, _ url :URL , _ error : Error?) -> Void



/// Class for downloading images from url and storing it in the cache
class ImageDownloader {
    var imageDwnLoaderQueue : OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.kaps.ImageCaching"
        queue.qualityOfService = .userInteractive
        return queue
    }()
    let myImageCache = NSCache<NSString,UIImage>()
    var myCompletionHandler : ImageDownloadHandler?
    static let shared = ImageDownloader()
    private init () {}
    
    
    /// function to download images for  a particular url
    ///
    /// - Parameters:
    ///   - urlString: image url
    ///   - handler: completion handler for handling the response
    func downloadImageFor(url urlString : String, handler : @escaping ImageDownloadHandler) {
        self.myCompletionHandler = handler
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        if let image = myImageCache.object(forKey: urlString as NSString) {
            self.myCompletionHandler?(image,url,nil)
        }else{
            if let operations = (imageDwnLoaderQueue.operations as? [KSOperation])?.filter({$0.imageUrl?.absoluteString == urlString && $0.isFinished == false}), let operation = operations.first{
                operation.queuePriority = .veryHigh
            }else{
                let operation = KSOperation(url: URL(string: urlString)!)
                operation.downloadHandler = { image, url, error in
                    if let newImage = image {
                        self.myImageCache.setObject(newImage, forKey: url.absoluteString as NSString)
                    }
                    self.myCompletionHandler?(image, url, error)
                    
                }
                imageDwnLoaderQueue.addOperation(operation)
            }
        }
    }
    
}
