//
//  Post.swift
//  Salaam
//
//  Created by basira daqiq on 7/11/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseDatabase.FIRDataSnapshot


class Post {
    var isLiked = false
    var likeCount: Int
    let poster: User
    var key: String?
    let creationDate: Date
    var textData: String?
    var textHeight: CGFloat
    var textWidth: CGFloat

    

    
    

    init(texts: String, textHeight: CGFloat, textWidth: CGFloat) {
        self.creationDate = Date()
        self.likeCount = 0
        self.poster = User.current
        self.textData = texts
        self.textHeight = textHeight
        self.textWidth = textWidth

    }
    
    var dictValue: [String : Any] {
        let createdAgo = creationDate.timeIntervalSince1970
        let userDict = ["uid" : poster.uid,
                        "username" : poster.username,
                        "text" : textData]
        
        
        //1) add message field and set to textData. Test to see if message appears in Firebase.
        //2) Call the reload data function for your home view controller table view
        
        
        
        return ["created_at" : createdAgo,
                "like_count" : likeCount,
                "poster" : userDict,
                "textHeight": textHeight,
                "textWidth": textWidth]
    }
    init?(snapshot: DataSnapshot) {
        
        guard let dict = snapshot.value as? [String : Any] else {
            print("no data: \(snapshot.key)\n \(snapshot)")
            return nil
        }
        
        guard let createdAgo = dict["created_at"] as? TimeInterval,
            let likeCount = dict["like_count"] as? Int,
            let userDict = dict["poster"] as? [String : Any],
            let uid = userDict["uid"] as? String,
            let username = userDict["username"] as? String,
            let textHeight = dict["textHeight"] as? CGFloat,
            let textWidth = dict["textWidth"] as? CGFloat,
            let text = userDict["text"] as? String
            else { return nil }
        // why/
        
        self.textData = text
        //
        self.likeCount = likeCount
        self.poster = User(uid: uid, username: username)
        //
        self.key = snapshot.key
        self.creationDate = Date(timeIntervalSince1970: createdAgo)
        //self.textData =
        self.textHeight = CGFloat(textHeight)
        self.textWidth = CGFloat(textWidth)

    }
}

