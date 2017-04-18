//
//  Comment.swift
//  TimeLine
//
//  Created by Bradley GIlmore on 4/17/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import Foundation

class Comment: SearchableRecord{
    
    //MARK: - Internal Properties
    
    let text: String
    let timestamp: Date
    let post: Post
    
    
    //Initializers
    
    init(text: String, timestamp: Date = Date(), post: Post){
        
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    
    //Search Record Function
    
    func matches(searchTerm: String) -> Bool {
        return text.contains(searchTerm)
    }
    
}
