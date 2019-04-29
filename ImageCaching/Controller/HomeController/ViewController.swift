//
//  ViewController.swift
//  ImageCaching
//
//  Created by Kapil on 4/28/19.
//  Copyright © 2019 Kapil. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
    
    var imagesArray : [FlickrImage] = []
    var viewModel : ViewModel!
    var searchText : String = ""
    var pageNumber = 0
    var loadMore = true;
    var backgroundView : UILabel!
    var indexPathMap =  [URL:IndexPath]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpInitialUI()
        self.navigationItem.title = "Flickr Search App"
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    private func bindData() {
        viewModel.reloadData = {
            DispatchQueue.main.async {
                self.imageCollectionView.backgroundView = nil
                self.imageCollectionView.performBatchUpdates({
                    self.imageCollectionView.insertItems(at: self.viewModel.insertIndexPathArray())
                }, completion: nil)
            }
        }
        
        viewModel.showMessage = {msg in
            DispatchQueue.main.async {
                self.backgroundView = UILabel()
                self.backgroundView.frame = self.imageCollectionView.bounds
                self.backgroundView.textColor = UIColor.gray
                self.backgroundView.textAlignment = .center
                self.backgroundView.numberOfLines = 0
                self.backgroundView.text = msg
                self.imageCollectionView.backgroundView = self.backgroundView
                self.imageCollectionView.reloadData()
            }
            
        }
        
        
        //// and so on
    }
    
    func setUpInitialUI(){
        searchText = "Apple"
        searchBar.placeholder = "Type Something to search.."
        searchBar.text = "Kittens"
        viewModel = ViewModel()
        bindData()
        searchBar.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.keyboardDismissMode = .onDrag
    }
    
}



extension ViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItemsInSection(section: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.backgroundColor = UIColor.white
        DispatchQueue.main.async {
            cell.imageView.image = #imageLiteral(resourceName: "placeholder.png")
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        
            switch kind {
            case UICollectionView.elementKindSectionFooter:
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footerView", for: indexPath) as! SearchFooterReusableView
                
                if viewModel.isDataArrayEmpty() || !viewModel.loadMore{
                    footerView.isHidden = true
                }else{
                    footerView.isHidden = false
                }
                return footerView
                
            default:
                
                assert(false, "Unexpected element kind")
            }
            
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if viewModel.shouldLoadMore(indexPath)  {
            viewModel.retrieveData(withSearchQuery: searchText, andPage: pageNumber + 1)
            pageNumber = pageNumber + 1
        }
        
        let jsonObject = viewModel.flickrObjectAtIndexPath(indexPath)
        guard let url =  URL(string: "https://farm\(jsonObject.farm).staticflickr.com/\(jsonObject.server)/\(jsonObject.photoID)_\(jsonObject.secret)_\("m").jpg") else{
            return
        }
        indexPathMap[url] = indexPath
        print("setting data in indexMap : %d",indexPath.row)
        ImageDownloader.shared.downloadImageFor(url: (url.absoluteString)) { (image, url, error) in
            DispatchQueue.main.async {
                
                if let indexpathObtained = self.indexPathMap[url], let imageCell = collectionView.cellForItem(at: indexpathObtained) as? ImageCollectionViewCell{
                    print("getting cell in indexMap for indexpath : %d",indexpathObtained.row)
                    imageCell.imageView.image = image
                }
            }
        }
    }
    
    
}

extension ViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeOfItem = (collectionView.frame.size.width-30)/3
        return CGSize(width: sizeOfItem, height: sizeOfItem)
    }
}


extension ViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //
        pageNumber = 0
        searchText = searchBar.text!
        self.loadMore = true
        indexPathMap.removeAll()
        viewModel.resetArray()
        searchBar.resignFirstResponder()
        viewModel.retrieveData(withSearchQuery: searchBar.text!, andPage: 0)
    }
    
}
