//
//  ViewController.swift
//  MemeMe
//
//  Created by Guanqun Mao on 10/27/15.
//  Copyright © 2015 Guanqun Mao. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    var meme = Meme()
    var currText: UITextField?
    var imagePicker = UIImagePickerController()
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 1),
        NSForegroundColorAttributeName: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -5
    ]
    
    @IBAction func showImages(sender: UIBarButtonItem) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func showCamera(sender: AnyObject) {
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func showActivity(sender: UIBarButtonItem) {
        let image = UIImage()
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.save()
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    @IBAction func cancelActivity(sender: UIBarButtonItem) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func showAlert(sender: UIButton) {
        let alertController = UIAlertController()
        let okAction = UIAlertAction(title: "This is Title", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.contentMode = .ScaleAspectFit
            imagePickerView.image = image
            
            topText.defaultTextAttributes = memeTextAttributes
            topText.hidden = false
            topText.textAlignment = NSTextAlignment.Center
            
            bottomText.defaultTextAttributes = memeTextAttributes
            bottomText.hidden = false
            bottomText.textAlignment = NSTextAlignment.Center
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func save() {
        // Move view origin to (0,0)
        unsubscribeFromKeyboardNotifications()
        view.frame.origin.y = 0
        // Create the meme
        let memedImage = generateMemedImage()
        let meme = Meme( topText: topText.text!, bottomText: bottomText.text!, image:imagePickerView.image!, memedImage: memedImage)
        self.meme = meme
        // Add it to the memes array in the Application Delegate
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
        UIImageWriteToSavedPhotosAlbum(memedImage, nil, nil, nil)
    }
    
    // Create a UIImage that combines the Image View and the Textfields
    func generateMemedImage() -> UIImage {
        // render view to an image
        if UIScreen.mainScreen().respondsToSelector("scale"){
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(view.frame.size.width, view.frame.size.height),false,UIScreen.mainScreen().scale);
        }else{
            UIGraphicsBeginImageContext(view.frame.size);
        }
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return memedImage
    }
    
    //////////////// Textfield /////////////////////////
    func textFieldDidBeginEditing(textField: UITextField) {
        currText = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        currText = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    ///////////////// Textfield End ////////////////////
    
    ///////////////// Keyboard /////////////////////////
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomText == currText {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    ///////////////// Keyboard End //////////////////////
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications()
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        topText.delegate = self
        bottomText.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
}

