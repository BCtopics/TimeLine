//
//  Post.swift
//  TimeLine
//
//  Created by Bradley GIlmore on 4/17/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit
import CloudKit

class Post: SearchableRecord {
    
    //MARK: - Keys
    
    static let kType = "Post"
    static let kPhotoData = "photoData"
    static let kTimeStamp = "timestamp"
    
    //MARK: - Internal Properties
    
    let photoData: Data?
    let timestamp: Date
    var comments: [Comment]
    var photo: UIImage? {
        guard let data = self.photoData else { return nil }
        return UIImage(data: data)
    }
    
    var recordType: String { return Post.kType }
    
    fileprivate var temporaryPhotoURL: URL {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        try? photoData?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    var cloudKitRecordID: CKRecordID?
    
    //MARK: - Initializers
    
    init(photoData: Data?, timestamp: Date = Date(), comments: [Comment] = [Comment]()){
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
    }
    
    // MARK: CloudKitSyncable
    
    convenience required init?(record: CKRecord) {
        
        guard let timestamp = record.creationDate,
            let photoAsset = record[Post.kPhotoData] as? CKAsset else { return nil }
        
        let photoData = try? Data(contentsOf: photoAsset.fileURL)
        self.init(photoData: photoData, timestamp: timestamp)
        cloudKitRecordID = record.recordID
    }

    
    
    //Search Record Function

    func matches(searchTerm: String) -> Bool {
        let Comments = comments.filter { $0.matches(searchTerm: searchTerm) }
        return !Comments.isEmpty
    }
    
}

extension CKRecord {
    convenience init(_ post: Post){
    
    let recordID = CKRecordID(recordName: UUID().uuidString)
    self.init(recordType: post.recordType, recordID: recordID)
    
    self[Post.kPhotoData] = CKAsset(fileURL: post.temporaryPhotoURL)
    self[Post.kTimeStamp] = post.timestamp as CKRecordValue?
    }
}


