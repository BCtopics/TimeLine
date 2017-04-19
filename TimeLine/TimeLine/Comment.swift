//
//  Comment.swift
//  TimeLine
//
//  Created by Bradley GIlmore on 4/17/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import Foundation
import CloudKit

class Comment: SearchableRecord, CloudKitSyncable{
    
    //MARK: - Keys
    
    static let kType = "Comment"
    static let kText = "text"
    static let kPost = "post"
    static let kTimeStamp = "timestamp"
    
    //MARK: - Internal Properties
    
    let text: String
    let timestamp: Date
    var post: Post?
    
    var recordType: String {
        return Comment.kType
    }
    
    var cloudKitRecordID: CKRecordID?
    
    //Initializers
    
    init(text: String, timestamp: Date = Date(), post: Post?){
        
        self.text = text
        self.timestamp = timestamp
        self.post = post
    }
    
    
    convenience required init?(record: CKRecord) {
        
        guard let timestamp = record.creationDate,
            let text = record[Comment.kText] as? String else { return nil }
        
        self.init(text: text, timestamp: timestamp, post: nil)
        cloudKitRecordID = record.recordID
    }
    
    
    
    
    //Search Record Function
    
    func matches(searchTerm: String) -> Bool {
        return text.contains(searchTerm)
    }
    
}

extension CKRecord {
    convenience init(_ comment: Comment) {
        guard let post = comment.post else { fatalError("Comment does not have a Post relationship") }
        let postRecordID = post.cloudKitRecordID ?? CKRecord(post).recordID
        let recordID = CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: comment.recordType, recordID: recordID)
        
        self[Comment.kTimeStamp] = comment.timestamp as CKRecordValue?
        self[Comment.kText] = comment.text as CKRecordValue?
        self[Comment.kPost] = CKReference(recordID: postRecordID, action: .deleteSelf)
    }
}
