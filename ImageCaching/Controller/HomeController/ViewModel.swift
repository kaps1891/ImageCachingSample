//
//  ViewModel.swift
//  ImageCaching
//
//  Created by Kapil on 4/28/19.
//  Copyright © 2019 Kapil. All rights reserved.
//

import Foundation


let apiKey = "3e7cc266ae2b0e0d78e279ce8e361736"


protocol ViewModelProtocol {
    
    func flickrObjectAtIndexPath(_ indexpath : IndexPath) -> FlickrImage
    func isDataArrayEmpty() -> Bool
    func resetArray()
    func numberOfItemsInSection(section:Int) -> Int
    func numberOfSections() -> Int
    func shouldLoadMore(_ indexPath:IndexPath) -> Bool
    func insertIndexPathArray() -> [IndexPath]
}

class ViewModel : NSObject, ViewModelProtocol {
    
    
    
    private var dataArray = [FlickrImage]()
    let kNumberOfSectionsInCollectionView = 1
    var selectedCellIndexPath : IndexPath!
    var pageNumber = 0
    var searchText = "Kittens"
    var loadMore = true
    var indexPathMap =  [URL:IndexPath]()
    
    // Binders
    var reloadData: (() -> ())?
    var showMessage: ((String) -> ())?
    var start = 0
    var end = 0
    
    
    override init(){
        super.init()
        retrieveData(withSearchQuery: searchText,andPage: 0)
        
    }
    
    func flickrObjectAtIndexPath(_ indexpath : IndexPath) -> FlickrImage{
        return dataArray[indexpath.row]
    }
    
    func isDataArrayEmpty() -> Bool {
        return dataArray.isEmpty
    }
    
    func resetArray()  {
        dataArray = [FlickrImage]()
    }
    
    func insertIndexPathArray() -> [IndexPath]{
        let insertIndexPaths = Array(start...end-1).map { IndexPath(item: $0, section: 0) }
        return insertIndexPaths
    }
    
    /// Function to retrieve Data for the text entered in the searchbar
    ///
    /// - Parameters:
    ///   - searchText: Text enetered in the searchbar
    ///   - page: pageNumber for pagination
    func retrieveData(withSearchQuery searchText:String,andPage page:Int){
        pageNumber = page
        DataManager.sharedInstance.getData(withSearchQuery: searchText,andPage:page , callback: {[weak self] result,msg in
            DispatchQueue.main.async {
                if(result.count==0){
                    self?.loadMore = false
                    if(msg == ""){
                        if(self?.dataArray.count == 0){
                            self?.showMessage?("No Data Found for \(searchText)")
                            return
                        }
                    }
                }
                if(msg == ""){
                    self?.start = self?.dataArray.count ?? 0
                    self?.dataArray.append(contentsOf: result)
                    self?.end = self?.dataArray.count ?? 0
                    self?.reloadData?()
                }else{
                    self?.loadMore = false
                    self?.showMessage?("No Data Found")
                }
            }
        })
    }
    
    func numberOfItemsInSection(section:Int) -> Int{
        return dataArray.count
    }
    
    
    func numberOfSections() -> Int {
        return kNumberOfSectionsInCollectionView
    }
    
    
    /// Function to determine whether pagination call should be made or not
    ///
    /// - Parameter indexPath: indexpath for the visible item
    /// - Returns: boolean 
    func shouldLoadMore(_ indexPath:IndexPath) -> Bool{
        if (indexPath.row + 1 == dataArray.count && self.loadMore) {
            return true
        }
        return false
    }
    
}


