//
//  ImageCell.swift
//  GiphyProject
//
//  Created by Dmitry Preobrazhenskiy on 28/06/16.
//  Copyright © 2016 Example. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import SwiftyJSON

let ImageCellIdentifier = "imageCellIdentifier"

public class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    public func updateWithGIF(gif: GIF) {
        guard let images = gif.images else {
            return
        }
        
        let original = images["original"]?.dictionaryValue
        let originalURL = original?["url"]?.stringValue
        
        guard let url = originalURL else {
            return
        }
        
        let imageURL = NSURL.init(string: url)!
        
        imageView.sd_setImageWithURL(imageURL, placeholderImage: UIImage.init(named: "placeholder"))
    }
}
