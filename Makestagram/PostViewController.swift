//
//  PostViewController.swift
//  Salaam
//
//  Created by basira daqiq on 7/14/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
    
    
    
    
    @IBAction func cancelButtonTopped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let identifier = segue.identifier
        if identifier == "cancel"{
            print("Cancel button tapped")
            textViewWrite.text = ""
        } else if identifier == "save" {
            print("Save button tapped")
            
            if textViewWrite.text == "" {
                print("text empty")
                
            } else if isItLegit(size: textViewWrite.text.characters.count)  {
                
                print("\(textViewWrite.contentSize.height)")
                
                let size: CGSize = textViewWrite.sizeThatFits(CGSize.init(width: textViewWrite.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
                let insets: UIEdgeInsets = textViewWrite.textContainerInset;
                let relevantHeight = size.height - insets.top - insets.bottom;
                
                let text = Post(texts: "String", textHeight: relevantHeight, textWidth: textViewWrite.contentSize.width)
                PostService.create(text: self.textViewWrite.text!, height: Int(textViewWrite.contentSize.height), width: Int(view.frame.width) )
                print("\(textViewWrite.contentSize.height)")
                
                // 1
                let HomeViewController = segue.destination as! HomeViewController
                // 2
                HomeViewController.posts.append(text)
                textViewWrite.text = ""

            }
            
            else{
                let alertController = UIAlertController(title: "your text is too long!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
            }
        }
    }
    
    @IBAction func submitButtonTopped(_ sender: UIButton) {
        //   let text = textField.text ?? ""
        print("HELOOOOOO")
        // sav creat an ansetense and save teh text inn the text view of ur post  textField.text =
        
    }
    
    @IBOutlet weak var textViewWrite: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    
    func isItLegit(size: Int) -> Bool{
        
        if size <= 1200 {
            return true
        }
        else {
            
        return false
        
    }
    }
 
    
   
    
    
    //    let photoHelper = MGPhotoHelper()
    override func viewDidLoad() {
        super.viewDidLoad()
        /*  the code for done button
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        
        let ViewForDoneButtonOnKeyboard = UIToolbar()
        ViewForDoneButtonOnKeyboard.sizeToFit()
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: #selector(PostViewController.dismissKeyboard))
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(PostViewController.dismissKeyboard))
        ViewForDoneButtonOnKeyboard.setItems([flexButton, doneButton], animated: true)
        
        
               textViewWrite.inputAccessoryView = ViewForDoneButtonOnKeyboard
        */
        
    }
    
    
    
    fileprivate func  observeKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            UIView.animate(withDuration: 0.2, animations: {
                self.view.frame.origin.y = -keyboardHeight
            })
        }
           }
    
    // will properly hide keyboard
    func keyboardWillHide(sender: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame.origin.y = 0
        })
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        dismissKeyboard()
        return true
    }
    
    // END
    
    @IBAction func picPicker(_ sender: UIButton) {
        
        // photoHelper.presentActionSheet(from: self)
    }
}
