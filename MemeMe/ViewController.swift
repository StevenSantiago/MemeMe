//
//  ViewController.swift
//  ImagePick
//
//  Created by Steven on 8/28/17.
//  Copyright © 2017 Steven Santiago. All rights reserved.
//TODO: TextFields will not center correctly

import UIKit


struct MemeObject{
    var top:String
    var bottom:String
    var originalImage:UIImage!
    var memedImage:UIImage!
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var imagePick: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var topToolBar: UIToolbar!
    
    var meme:MemeObject!

    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextField(textField: topTextField)
        setUpTextField(textField: bottomTextField)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        if(imagePick.image != nil){
            shareButton.isEnabled = true
        } else {
            shareButton.isEnabled = false
        }
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imagePick.image = image
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
    //Keyboard functions
    
    //keyboardWillShow will slide view up only if bottomTextField is clicked
    func keyboardWillShow(notification: NSNotification) {
        if(bottomTextField.isFirstResponder){
        self.view.frame.origin.y -= getKeyboardHeight(notification: notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        self.view.frame.origin.y = 0 // set back to original view frame location
    }
    
    func subscribeToKeyboardNotifications() {
        //adds observers for keyboardWillShow and keyboardWillHide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)

    }
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        //notifications stores info in userinfo which is a dictionary 
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    //
    
    // IBActions
    @IBAction func choosePic(_ sender: UIBarButtonItem) {
        let controller = UIImagePickerController()
        controller.delegate = self
        if(sender.tag == 0) {
        controller.sourceType = .photoLibrary
        } else {
        controller.sourceType = .camera
        }
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func sharePic(_ sender: UIButton) {
        let controller = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        controller.completionWithItemsHandler = { activity, success, items, error in
            self.save()
        }
        present(controller, animated: true, completion: nil)
    }
    
    //
    
    //TextField functions
    //NOTE: Centering issues comes up when textAlignment is called before defaultTExtAttributes
    func setUpTextField(textField: UITextField){
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.text = "TEXT GOES HERE"
        textField.delegate = self
    }
    
  
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //
    
    
    //Meme Object functions
    func save() {
        meme = MemeObject(top: topTextField.text!, bottom: bottomTextField.text!, originalImage: imagePick.image!, memedImage: generateMemedImage())
    }
    
    func hideElements(_ hide:Bool){
            toolBar.isHidden = hide
            topToolBar.isHidden = hide
    }
    
    func generateMemedImage() -> UIImage {
        hideElements(true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        hideElements(false)
        return memedImage
    }
    
}


