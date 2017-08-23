//
//  UserService.swift
//  Salaam
//
//  Created by basira daqiq on 7/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

struct UserService {
    static func create(_ firUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
        let userAttrs = ["username": username]
        
        let ref = Database.database().reference().child("users").child(firUser.uid)
        ref.setValue(userAttrs) { (error, ref) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                let user = User(snapshot: snapshot)
                completion(user)
            })
            
        }
        
    }
    
    static func followers(for user: User, completion: @escaping ([String]) -> Void) {
        let followersRef = Database.database().reference().child("followers").child(user.uid)
        
        followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let followersDict = snapshot.value as? [String : Bool] else {
                return completion([])
            }
            
            let followersKeys = Array(followersDict.keys)
            completion(followersKeys)
            
        })
        
    }
    
    
    static func timeline(completion: @escaping ([Post]) -> Void) {
        let currentUser = User.current
        
        let timelineRef = Database.database().reference().child("timeline").child(currentUser.uid)
        timelineRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                else { return completion([]) }
            
            let dispatchGroup = DispatchGroup()
            
            var posts = [Post]()
            
            //dispatchGroup.enter()
            
            for postSnap in snapshot {
                guard let postDict = postSnap.value as? [String : Any],
                    let posterUID = postDict["poster_uid"] as? String
                    else { continue }
                
                dispatchGroup.enter()

//                PostService.show(posterUID: posterUID, completion: { ([Post]?) in
                print("fetching post: UID:\(postSnap.key) posterUID:\(posterUID)")
                PostService.showLike(forKey: postSnap.key, posterUID: posterUID) { (post) in
                    if let post = post {
                        posts.append(post)
                    }
                    
                    dispatchGroup.leave()
                }
            }
            //print(posts)
            //completion(posts.reversed())
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts.reversed())
            })
        })
    }
    
    
    
    
    // func for blokedusers retriving blocked blocked users
    static func blockedUsers(completion: @escaping ([String : Bool]) -> Void){
       
        let blockedUserRef = Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("blockedUsers")
        blockedUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String:Bool] else {
                return completion([:])
            }
            completion(dict)
        })
        
        
       
    }
    
    
    static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void) {
        let currentUser = User.current
        let ref = Database.database().reference().child("users")

        //where we hold all teh blocked uerse dict
        // empty dict and
        // chhange teh block dict to be the return volue
        //
        var blockedDict = [String:Bool]()
        blockedUsers { (dict) in
            blockedDict = dict
            // start pulling all volues users
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
                    else { return completion([]) }
                //2.
                //
                let users =
                    snapshot
                        .flatMap(User.init)
                        .filter {
                            // if user part of block dict
                            let value : Bool = blockedDict[$0.uid] ?? false
                            return !value &&
                                $0.uid != currentUser.uid
                }
                
                let dispatchGroup = DispatchGroup()
                users.forEach { (user) in
                    dispatchGroup.enter()
                    
                    FollowService.isUserFollowed(user) { (isFollowed) in
                        user.isFollowed = isFollowed
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main, execute: {
                    completion(users)
                })
            })
        }
        
        
    }
    
    
    static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
        let ref = Database.database().reference().child("users").child(uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = User(snapshot: snapshot) else {
                return completion(nil)
            }
            
            completion(user)
        })
    }
    
    
    static func posts(for user: User, completion: @escaping ([Post]) -> Void) {
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                return completion([])
            }
            
            let dispatchGroup = DispatchGroup()
            
            let posts: [Post] =
                snapshot
                    .reversed()
                    .flatMap {
                        guard let post = Post(snapshot: $0)
                            else { return nil }
                        
                        dispatchGroup.enter()
                        
                        LikeService.isPostLiked(post) { (isLiked) in
                            post.isLiked = isLiked
                            
                            dispatchGroup.leave()
                        }
                        
                        return post
            }
            
            dispatchGroup.notify(queue: .main, execute: {
                completion(posts)
            })
        })
    }
    
    
//block
    static func block(myself: String, posterUID:  String){
        let blockedUserRef = Database.database().reference().child("users").child(myself).child("blockedUsers").child(posterUID)
        blockedUserRef.setValue(true)
        
        let blockedbyRef = Database.database().reference().child("users").child(posterUID).child("blockedUsers").child(myself)
        blockedbyRef.setValue(true)
 
    }
    
    
    // ...
}


