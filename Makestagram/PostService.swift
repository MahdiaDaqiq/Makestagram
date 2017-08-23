//
//  PostService.swift
//  Salaam
//
//  Created by basira daqiq on 7/11/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import Firebase


struct PostService {
          
   
    static func showLike(forKey postKey: String, posterUID: String, completion: @escaping (Post?) -> Void) {
        let ref = Database.database().reference().child("posts").child(posterUID).child(postKey)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let post = Post(snapshot: snapshot) else {
                return completion(nil)
            }

            LikeService.isPostLiked(post) { (isLiked) in
                post.isLiked = isLiked
                completion(post)
            }
        })
    }
 

    
    static func show(posterUID: String, completion: @escaping ([Post]?) -> Void) {
        
        //THIS IS THE ONE THAT WAS CALLED WHEN SEAN WAS HELPING WOOT
        let currentUID = User.current.uid

        
 
        let ref = Database.database().reference().child("posts").child(posterUID)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var postArray = [Post]()
            
            if let posts = snapshot.children.allObjects as? [DataSnapshot] {
                for post in posts {
                    
                    let myPost = Post(snapshot: post)
                    print("Current post:")
                    print("Text data: \(String(describing: myPost?.textData))")
                    
                    postArray.append(myPost!)
                }
            }
            
            completion(postArray)
            
        })
    }
    
    static func create(text: String, height: Int, width: Int) {
        // 1
        print("The text for this post is \(text) and its height is \(height)")
        let currentUser = User.current
        // 
        let post = Post(texts: text, textHeight: CGFloat(height), textWidth: CGFloat(width))
        // 3
        //let dict = post.dictValue
        
        let rootRef = Database.database().reference()
        let newPostRef = rootRef.child("posts").child(currentUser.uid).childByAutoId()
        let newPostKey = newPostRef.key
        
        // 2
        UserService.followers(for: currentUser) { (followerUIDs) in
            // 3
            let timelinePostDict = ["poster_uid" : currentUser.uid]
            
            
            // 4
            var updatedData: [String : Any] = ["timeline/\(currentUser.uid)/\(newPostKey)" : timelinePostDict]
            
            // 5
            
            
            for uid in followerUIDs {
                updatedData["timeline/\(uid)/\(newPostKey)"] = timelinePostDict
            }
            
            // 6
            let postDict = post.dictValue
            updatedData["posts/\(currentUser.uid)/\(newPostKey)"] = postDict
            
            // 7
            rootRef.updateChildValues(updatedData)
        }
       
    }
    
    // flag 1
    
    static func flag(_ post: Post) {
        // 1
        guard var postKey = post.key else { return }
        
        // 2
        
    }
    
  
}


