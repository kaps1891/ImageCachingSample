//
//  SearchFooterReusableView.swift
//  ImageCaching
//
//  Created by Kapil on 4/28/19.
//  Copyright © 2019 Kapil. All rights reserved.
//

import UIKit

/// Footer View for the CollectionView
class SearchFooterReusableView: UICollectionReusableView {
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingIndicatorView.startAnimating()
    }
    
}
