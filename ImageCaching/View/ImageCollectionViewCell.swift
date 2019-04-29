//
//  ImageCollectionViewCell.swift
//  ImageCaching
//
//  Created by Kapil on 4/28/19.
//  Copyright © 2019 Kapil. All rights reserved.
//

import UIKit


class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func prepareForReuse() {
        imageView.image = nil
        imageView.image = #imageLiteral(resourceName: "placeholder.png")
    }
}
