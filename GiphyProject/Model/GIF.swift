//
//  GIF.swift
//  GiphyProject
//
//  Created by Dmitry Preobrazhenskiy on 28/06/16.
//  Copyright © 2016 Example. All rights reserved.
//

import Foundation
import SwiftyJSON

public class GIF {
    
    private let localAttributes: JSON?
    let id: String?
    let images: [String: JSON]?
    let slug: String?
    let source: String?
    
    init(attributes: JSON) {
        localAttributes = attributes
        id = attributes["id"].stringValue
        slug = attributes["slug"].stringValue
        source = attributes["source"].stringValue
        images = attributes["images"].dictionaryValue
    }
}