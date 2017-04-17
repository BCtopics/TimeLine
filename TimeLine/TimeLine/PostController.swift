//
//  PostController.swift
//  TimeLine
//
//  Created by Bradley GIlmore on 4/17/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class PostController {
    
    // Singleton Instance
    
    static let sharedController = PostController()
    
    
    //MARK: - Internal Properties
    
    var posts = [Post]()
    
    //MARK: - CRUD
    
    func createPostWith(image: UIImage, caption: String){
        guard let data = UIImageJPEGRepresentation(image, 0.8) else { return }
        
        let post = Post(photoData: data)
        let _ = addComment(toPost: post, text: caption)
        posts.append(post)
    }
    
    func addComment(toPost: Post, text: String){
        let comment = Comment(text: text, post: toPost)
        toPost.comments.append(comment)
    }
    
    
    
    
    
    
}
