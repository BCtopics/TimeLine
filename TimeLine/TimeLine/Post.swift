//
//  Post.swift
//  TimeLine
//
//  Created by Bradley GIlmore on 4/17/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class Post {
    
    //MARK: - Internal Properties
    
    let photoData: Data?
    let timestamp: Date
    let comments: [Comment]
    var photo: UIImage? {
        guard let data = self.photoData else { return nil }
        return UIImage(data: data)
    }
    
    //MARK: - Initializers
    
    init(photoData: Data?, timestamp: Date = Date(), comments: [Comment] = [Comment]()){
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
    }
    
}
