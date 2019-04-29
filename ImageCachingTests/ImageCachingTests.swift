//
//  ImageCachingTests.swift
//  ImageCachingTests
//
//  Created by Kapil on 4/28/19.
//  Copyright © 2019 Kapil. All rights reserved.
//

import XCTest

@testable import ImageCaching


class ImageCachingTests: XCTestCase {
    var viewModel: ViewModel!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = ViewModel()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
    }
    
    
    
    /// Test function to test whether that particular image is being downloaded with the particular indexpath being returned.
    func testImageDownloading(){
        
        var finalResult : UIImage?
        var err : Error?
        var urlPassed : URL?
        
        let expectation = XCTestExpectation(description: "Image download test")
        
        guard let urlCheck = URL(string: "https://farm66.staticflickr.com/65535/47678544612_8aca2e841c_m.jpg") else {
            return
        }
        ImageDownloader.shared.downloadImageFor(url: urlCheck.absoluteString) { (imgResult, urlResult, error) in
            
            finalResult = imgResult
            err = error
            urlPassed = urlResult
            expectation.fulfill()
            
        }
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(finalResult != nil, "NO data...")
        
        XCTAssertTrue(err == nil)
        
        XCTAssertEqual(urlPassed?.absoluteString, urlCheck.absoluteString, "Both URLs should be the same")
        
        
    }
    
    
    
    
    /// Test function to test whether the api is returning results within given time.
    func testImageFetching2() {
        let text = "hello"
        let pageNumber = 0
        
        let expectation = XCTestExpectation(description: "api test")
        
        var finalResult : [FlickrImage]?
        var message : String?
        
        DataManager.sharedInstance.getData(withSearchQuery: text, andPage: pageNumber) { (result, msg) in
            finalResult = result
            message = msg
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
        
        
        // made our necessay checks
        XCTAssertTrue((finalResult?.count ?? 0) > 0, "NO data...")
        
        XCTAssertTrue((message?.isEmpty ?? false))
        
        
    }
    
    
    
    /// Test function to serialize data to our custom objects from locally loaded data.
    func testSerializationOfData(){
        
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "fakeData", ofType: "json")
        if let data = try? Data(contentsOf: URL(fileURLWithPath: path!), options: .alwaysMapped) {
            let decoder = JSONDecoder()
            let item = try? decoder.decode(FlickrObject.self, from: data)
            let photos = item?.photo.photos
            XCTAssertEqual(photos?.count, 30, "Didn't parse 30 items from fake response")
            
        }
    }
    
    
}



