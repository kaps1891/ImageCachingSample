//
//  KSOperation.swift
//  ImageCaching
//
//  Created by Kapil on 4/28/19.
//  Copyright © 2019 Kapil. All rights reserved.
//

import UIKit


/// An Operation for asynchronously download images
class KSOperation: Operation {
    
    var downloadHandler : ImageDownloadHandler?
    var imageUrl : URL?
    
    override var isAsynchronous: Bool {
        get {
            return  true
        }
    }
    
    var isTaskFinished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    var isTaskExecuting = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isFinished: Bool{
        return isTaskFinished
    }
    
    override var isExecuting: Bool{
        return isTaskExecuting
    }
    
    required init(url : URL) {
        self.imageUrl = url
    }
    
    override func main() {
        if self.isCancelled {
            self.isTaskFinished = true
            self.isTaskExecuting = false
            return
        }
        self.isTaskExecuting = true
        URLSession.shared.downloadTask(with: imageUrl!) { (location, response, error) in
            if let locationURl = location, let data = try? Data(contentsOf: locationURl) {
                let image = UIImage(data: data)
                self.downloadHandler?(image,self.imageUrl!,error)
                self.isTaskFinished = true
                self.isTaskExecuting = false
            }
        }.resume()
    }
    

}
