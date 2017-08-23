//
//  HomeViewController.swift
//  Salaam
//
//  Created by basira daqiq on 7/10/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase
import FirebaseAuth



class HomeViewController: UIViewController {
   
    @IBAction func logOutPressed(_ sender: UIButton) {
        print("Logout button pressed")
        AuthService.presentLogOut(viewController: self)
        

    }
   
    
    
    
    @IBOutlet weak var logOut: UIBarButtonItem!
    // sean's log out code 1
    var authHandle: AuthStateDidChangeListenerHandle?
    //
    
    let refreshControl = UIRefreshControl()
    
    var posts = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!

    let timestampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        print("blah")
        
        return dateFormatter
    }()
    
    
    override func viewDidLoad() {
 
        super.viewDidLoad()
        configureTableView()
        reloadTimeline()
        // logout2 code 2
        authHandle = AuthService.authListener(viewController: self)
        
        //
    }
    // logout 3
    deinit {
        AuthService.removeAuthListener(authHandle: authHandle)
    }
   //
    
    

    func configureTableView() {
        
        // remove separators for empty cells
        tableView.tableFooterView = UIView()
        // remove separators from cells
        tableView.separatorStyle = .none
        
        refreshControl.addTarget(self, action: #selector(reloadTimeline), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    
   
    func reloadTimeline() {
        posts = []
        var timelinePosts : [Post] = []
        let dispatcher = DispatchGroup()
        
        
        
       
        
        
        dispatcher.enter()
        UserService.timeline() { (posts) in
            timelinePosts.append(contentsOf: posts)
            dispatcher.leave()
        }
        dispatcher.notify(queue: .main, execute: {
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.posts = timelinePosts
            print(self.posts)
            self.tableView.reloadData()
        })
        
     
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1
        if let identifier = segue.identifier {
            // 2
            if identifier == "displaySetting" {
                // 3
                print("Transitioning to the Display Note View Controller")
            }
        }
    }
    
    
        @IBAction func unwindViewController(_ segue: UIStoryboardSegue) {
        
        // for now, simply defining the method is sufficient.
        // we'll add code later
        
        if let sourceViewController = segue.source as? PostViewController {
            if let postText = sourceViewController.textViewWrite.text {
                print(postText)
                
                //post service create method...
                //PostService.create(text: postText)
                reloadTimeline()
                
            }
        }
        
        print("unwind")
    }
    
    // flag 4 modified 6
    func handleOptionsButtonTap(from cell: PostHeaderCell) {
        // 1
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        // 2
        let post = posts[indexPath.section]
        let poster = post.poster
        let postKey = post.key
        let uid = poster.uid
// 3
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 4
        if poster.uid != User.current.uid {
            let flagAction = UIAlertAction(title: "Report as Inappropriate", style: .default) { _ in
                PostService.flag(post)
                
                /// addedflag
    
                let flaggedPostRef = Database.database().reference().child("flaggedPosts").child(postKey!)
                
                
                // 3
                let flaggedDict = ["text": post.textData,
                                   "poster_uid": post.poster.uid,
                                   "reporter_uid": User.current.uid]
                
                // 4
                flaggedPostRef.updateChildValues(flaggedDict)
                
                // 5
                let flagCountRef = flaggedPostRef.child("flag_count")
                flagCountRef.runTransactionBlock({ (mutableData) -> TransactionResult in
                    
                    
                    let currentCount = mutableData.value as? Int ?? 0
                    mutableData.value = currentCount

                if mutableData.value as! Int >= 2 {
                    
                    // the post for falgiin I love u hadi I tried so hard. U r so smart good job!
                    Database.database().reference().child("posts").child(uid).child(postKey!).removeValue()
            
                    print("Delete case: mutableData.value = \(String(describing: mutableData.value))")
                    
                } else {
                    print("Case not met. Either not equal to 2 or not able to cast as Integer type. The value of the casted in is \(mutableData.value as? Int)")
                }

                    mutableData.value = currentCount + 1
                    
                    
                    return TransactionResult.success(withValue: mutableData)
                })

                let okAlert = UIAlertController(title: nil, message: "The post has been flagged.", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(okAlert, animated: true)
            }
            
            alertController.addAction(flagAction)
        } else {
            let flagAction = UIAlertAction(title: "Delete post", style: .default) { _ in
                
                        Database.database().reference().child("posts").child(uid).child(postKey!).removeValue()
                        
                let okAlert = UIAlertController(title: nil, message: "The post has been deleted.", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(okAlert, animated: true)
            }
            
            alertController.addAction(flagAction)
            
        }
        
        ///added1 aded me to show the block button
        if poster.uid != User.current.uid {
            let blockAction = UIAlertAction(title: "Block this User", style: .default) { _ in
                
                let currentUser = User.current
                
              //  FollowService.unfollowUser(user: poster.uid )
                
                
                UserService.block(myself: currentUser.uid, posterUID : poster.uid)
                
                let currentUID = User.current.uid
                let followData = ["followers/\(uid)/\(currentUID)" : NSNull(),
                                  "following/\(currentUID)/\(uid)" : NSNull(),
                                  "followers/\(currentUID)/\(uid)" : NSNull(),
                                  "following/\(uid)/\(currentUID)" : NSNull()]
                
                               let ref = Database.database().reference()
                ref.updateChildValues(followData) { (error, ref) in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                    }
                    
                    UserService.posts(for: poster, completion: { (post) in
                        var unfollowData = [String : Any]()
                        let postsKeys = post.flatMap { $0.key }
                        postsKeys.forEach {
                            unfollowData["timeline/\(currentUID)/\($0)"] = NSNull()
                        }
                        
                        ref.updateChildValues(unfollowData, withCompletionBlock: { (error, ref) in
                            if let error = error {
                                assertionFailure(error.localizedDescription)
                            }
                            
                        })
                    })
                }
                
                
                
               

                let okAlert = UIAlertController(title: nil, message: "The user has been blocked.", preferredStyle: .alert)
                okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(okAlert, animated: true)

            }
            
            alertController.addAction(blockAction)
        }
        
        
        // 5
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // 6
        present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    //will signout an authenticated user
    //logout 4
    
    
    static func presentLogOut(viewController : UIViewController){
        let alertController = UIAlertController(title: "Are You Sure You Want To Log Out?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let logoutAction = UIAlertAction(title: "Log Out", style: .default){_ in
            logUserOut()
        }
        alertController.addAction(logoutAction)
        
        viewController.present(alertController, animated: true)
    }
    
    
    static func logUserOut(){
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            assertionFailure("Error signing out: \(error.localizedDescription)")
        }
        
    }
    
    //will allow user to return to login controller after they logout
    
    static func authListener(viewController view : UIViewController) -> AuthStateDidChangeListenerHandle {
        let authHandle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            guard user == nil else { return }
            
            let loginViewController = LoginViewController()
            view.view.window?.rootViewController = loginViewController
            view.view.window?.makeKeyAndVisible()
        }
        return authHandle
    }
    
    //use this to confirm user has logged out
    static func removeAuthListener(authHandle : AuthStateDidChangeListenerHandle?){
        if let authHandle = authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }
    ///
    ///  aded for sequelena thurs
    
    
    
}






extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        
        switch indexPath.row {
            /// flag 5
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostHeaderCell") as! PostHeaderCell
            cell.usernameLabel.text = post.poster.username
            
            cell.didTapOptionsButtonForCell = handleOptionsButtonTap(from:)
            return cell

            
        /*
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostHeaderCell") as! PostHeaderCell
            cell.usernameLabel.text = post.poster.username
            
            return cell
        */
        
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTextViewCell") as! PostTextViewCell
            
            
            cell.textView.text = posts[indexPath.section].textData!

          
            //
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostActionCell") as! PostActionCell
            cell.delegate = self
            configureCell(cell, with: post)
            
            return cell

        
        default:
            fatalError("Error: unexpected indexPath.")
        }
    }
        
        
        func configureCell(_ cell: PostActionCell, with post: Post) {
            cell.timeAgoLabel.text = timestampFormatter.string(from: post.creationDate)
            cell.likeButton.isSelected = post.isLiked
            cell.likeCountLabel.text = "\(post.likeCount) likes"
    }
    
    
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
 
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    
    }
}





extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return PostHeaderCell.height
            
        case 1:
            
            let post = posts[indexPath.section]

           return CGFloat(post.textHeight)

            
        case 2:
            return PostActionCell.height
            
        default:
            fatalError()
        }
    }
}





extension HomeViewController: PostActionCellDelegate {
    func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell) {
        // 1
        guard let indexPath = tableView.indexPath(for: cell)
            else { return }
        
        // 2
        likeButton.isUserInteractionEnabled = false
        // 3
        let post = posts[indexPath.section]
        
        // 4
        LikeService.setIsLiked(!post.isLiked, for: post) { (success) in
            // 5
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            
            // 6
            guard success else { return }
            
            // 7
            post.likeCount += !post.isLiked ? 1 : -1
            post.isLiked = !post.isLiked
            
            // 8
            guard let cell = self.tableView.cellForRow(at: indexPath) as? PostActionCell
                else { return }
            
            // 9
            DispatchQueue.main.async {
                self.configureCell(cell, with: post)
            }
        }
    }
}

