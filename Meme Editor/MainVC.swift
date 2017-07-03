//
//  MainVC.swift
//  Meme Editor
//
//  Created by gem on 7/2/17.
//  Copyright © 2017 gem. All rights reserved.
//

import UIKit

class MainVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    // TODO: have an undo cancel. When cancel is pressed hold initial values in variables then undo cancel can put the image and text fields back.
    //MARK: Outlets
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBAction func albumPressed(_ sender: UIBarButtonItem) {
        pickAnImage()
        
    }
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        takePicture()
    }
    @IBAction func actionPressed(_ sender: UIBarButtonItem) {
        shareMeme()
    }
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        clearMeme()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.backgroundColor = UIColor.white.cgColor
        setupTextFields()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeToKeyboardNotifications()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func setupTextFields() {
        let textFields = [topTextField, bottomTextField]
        let memeTextFieldAttributes: [String: Any] = [NSStrokeColorAttributeName: UIColor.black, NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!, NSStrokeWidthAttributeName: 3.0]
        
        for textField in textFields {
            textField?.delegate = self
            textField?.defaultTextAttributes = memeTextFieldAttributes
            textField?.textAlignment = .center
        }
        topTextField.placeholder = "top".uppercased()
        bottomTextField.placeholder = "bottom".uppercased()
    }
    func pickAnImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.mainImage.image = image
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    func shareMeme() {
        let meme = createMemedImage()
        let memeText = "My Memed Image"
        
        let activityController = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
        
    }
    func takePicture() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        self.present(imagePickerController, animated: true, completion: nil)
    }
    func saveMeme() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: (mainImage?.image!)!, memeImage: createMemedImage())
    }
    
    //MARK: Keyboard functions
    // If top text field is selected we don't want to move the view
    //TODO: check if I need to do something with the first responder before return on the top text field.
    func keyboardWillShow(_ notification: Notification) {
        
        if topTextField.isFirstResponder {
            return
        } else {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
            
        }
    }
    func keyboardWillHide(_ notification: Notification) {
        if topTextField.isFirstResponder {
            return
        } else {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
            
    }
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        return true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        view.endEditing(true)
    }
    func clearMeme() {
        self.mainImage.image = .none
        topTextField.text = ""
        bottomTextField.text = ""
    }
    func hideToolbars() {
        for toolbar in self.view.subviews where toolbar is UIToolbar {
            toolbar.isHidden = true
        }
    }
    func unHideToolbars() {
        for toolbar in self.view.subviews where toolbar is UIToolbar {
            toolbar.isHidden = false
        }
    }
    func createMemedImage() -> UIImage {
        hideToolbars()
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        unHideToolbars()
        return memedImage
    }
}
