//
//  PostController.swift
//  TimeLine
//
//  Created by Bradley GIlmore on 4/17/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    
    // Singleton Instance
    
    static let sharedController = PostController()
    
    
    //MARK: - Internal Properties
    
    var posts = [Post]()
    let cloudKitManager: CloudKitManager
    var comments: [Comment] {
        return posts.flatMap { $0.comments }
    }
    
    //MARK: - Initializers
    
    init(){
        self.cloudKitManager = CloudKitManager()
    }
    
    //MARK: - CRUD
    
    func createPostWith(image: UIImage, caption: String, completion: ((Post) -> Void)?){
        guard let data = UIImageJPEGRepresentation(image, 0.8) else { return }
        
        let post = Post(photoData: data)
        posts.append(post)
        let captionComment = addComment(toPost: post, text: caption)
        
        
        cloudKitManager.saveRecord(CKRecord(post)) { (record, error) in
            guard let record = record else {
                if let error = error {
                    NSLog("Error saving new post to CloudKit: \(error)")
                    return
                }
                completion?(post)
                return
            }
            post.cloudKitRecordID = record.recordID
    }
}
    
    func addComment(toPost: Post, text: String, completion: @escaping ((Comment) -> Void) = { _ in }) -> Comment {
        
        let comment = Comment(text: text, post: toPost)
        toPost.comments.append(comment)
        
        cloudKitManager.saveRecord(CKRecord(comment)) { (record, error) in
            if let error = error {
                NSLog("Error saving new comment to CloudKit: \(error)")
                return
            }
            comment.cloudKitRecordID = record?.recordID
            completion(comment)
        }
        
        return comment
    }
    
    // MARK: - Helper Fetches
    
    private func recordsOf(type: String) -> [CloudKitSyncable] {
        switch type {
        case "Post":
            return posts.flatMap { $0 as? CloudKitSyncable }
        case "Comment":
            return comments.flatMap { $0 as CloudKitSyncable }
        default:
            return []
        }
    }
    
    func syncedRecordsOf(type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { $0.isSynced }
    }
    
    func unsyncedRecordsOf(type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { !$0.isSynced }
    }
    
}
