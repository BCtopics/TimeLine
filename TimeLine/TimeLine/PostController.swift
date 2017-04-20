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
    
    var posts = [Post]() {
        didSet {
            DispatchQueue.main.async {
                let nc = NotificationCenter.default
                nc.post(name: PostController.PostsChangedNotification, object: self)
            }
        }
    }
    let cloudKitManager: CloudKitManager
    var comments: [Comment] {
        return posts.flatMap { $0.comments }
    }
    var isSyncing: Bool = false
    static let PostsChangedNotification = Notification.Name("PostsChangedNotification")
    static let PostCommentsChangedNotification = Notification.Name("PostCommentsChangedNotification")
    
    //MARK: - Initializers
    
    init(){
        self.cloudKitManager = CloudKitManager()
        performFullSync()
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
            completion?(post)
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
        
        DispatchQueue.main.async {
            let nc = NotificationCenter.default
            nc.post(name: PostController.PostCommentsChangedNotification, object: toPost)
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
    
    
    func fetchNewRecordsOf(type: String, completion: @escaping (() -> Void) = { _ in }) {
        
        var referencesNotWanted = [CKReference]()
        
        
        var predicate: NSPredicate!
        
        referencesNotWanted = self.syncedRecordsOf(type: type).flatMap { $0.cloudKitReference }
        predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referencesNotWanted])
        
        
        if referencesNotWanted.isEmpty {
            predicate = NSPredicate(value: true)
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            
            switch type {
            case Post.kType:
                if let post = Post(record: record) {
                    self.posts.append(post)
                }
            case Comment.kType:
                guard let postReference = record[Comment.kPost] as? CKReference,
                    let postIndex = self.posts.index(where: { $0.cloudKitRecordID == postReference.recordID }),
                    let comment = Comment(record: record) else { return }
                let post = self.posts[postIndex]
                post.comments.append(comment)
                comment.post = post
            default:
                return
            }
            
        }) { (records, error) in
            
            if let error = error {
                NSLog("Error fetching CloudKit records of type \(type): \(error)")
            }
            
            completion()
        }
    }
    
    func pushChangesToCloudKit(completion: @escaping ((_ success: Bool, _ error: Error?) -> Void) = { _,_ in }) {
        
        let unsavedPosts = unsyncedRecordsOf(type: Post.kType) as? [Post] ?? []
        let unsavedComments = unsyncedRecordsOf(type: Comment.kType) as? [Comment] ?? []
        var unsavedObjectsByRecord = [CKRecord: CloudKitSyncable]()
        for post in unsavedPosts {
            let record = CKRecord(post)
            unsavedObjectsByRecord[record] = post as? CloudKitSyncable
        }
        for comment in unsavedComments {
            let record = CKRecord(comment)
            unsavedObjectsByRecord[record] = comment
        }
        
        let unsavedRecords = Array(unsavedObjectsByRecord.keys)
        
        cloudKitManager.saveRecords(unsavedRecords, perRecordCompletion: { (record, error) in
            
            guard let record = record else { return }
            unsavedObjectsByRecord[record]?.cloudKitRecordID = record.recordID
            
        }) { (records, error) in
            
            let success = records != nil
            completion(success, error)
        }
    }
    
    func performFullSync(completion: @escaping (() -> Void) = { _ in }) {
        
        guard !isSyncing else {
            completion()
            return
        }
        
        isSyncing = true
        
        pushChangesToCloudKit { (success, error) in
            
            self.fetchNewRecordsOf(type: Post.kType) {
                
                self.fetchNewRecordsOf(type: Comment.kType) {
                    
                    self.isSyncing = false
                    
                    completion()
                }
            }
        }
        
    }
}
