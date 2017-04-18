//
//  Post.swift
//  TimeLine
//
//  Created by Bradley GIlmore on 4/17/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class Post: SearchableRecord {
    
    //MARK: - Internal Properties
    
    let photoData: Data?
    let timestamp: Date
    var comments: [Comment]
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
    
    
    //Search Record Function

    func matches(searchTerm: String) -> Bool {
        let Comments = comments.filter { $0.matches(searchTerm: searchTerm) }
        return !Comments.isEmpty
    }
    
}
