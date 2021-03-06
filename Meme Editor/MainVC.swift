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
    @IBOutlet var bothTextFields: [UITextField]!
    @IBOutlet var bothToolbars: [UIToolbar]!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBAction func albumPressed(_ sender: UIBarButtonItem) {
        presentImagePickerWith(sourceType: .photoLibrary)
    }
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        presentImagePickerWith(sourceType: .camera)
    }
    @IBAction func actionPressed(_ sender: UIBarButtonItem) {
        shareMeme()
    }
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        clearMeme()
    }
    //MARK: App lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.backgroundColor = UIColor.darkGray.cgColor
        setupTextFields()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribeToKeyboardNotifications()
    }
    
    func setupTextFields() {
        //NOTE: NSStrokeWidthAttributeName, a positive value only provides the outline, a zero value provides all fill and no outline, an negative value provides both the outline and fill color
        let textFields = [topTextField, bottomTextField]
        let memeTextFieldAttributes: [String: Any] = [NSStrokeColorAttributeName: UIColor.black, NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!, NSStrokeWidthAttributeName: -3.0]
        for textField in textFields {
            textField?.autocapitalizationType = .allCharacters
            textField?.delegate = self
            textField?.defaultTextAttributes = memeTextFieldAttributes
            textField?.textAlignment = .center
        }
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    //MARK: ImagePicker functions
    func presentImagePickerWith(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.mainImage.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: Meme image functions
    func shareMeme() {
        let memeImage = createMemedImage()
        let activityController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = { [weak self]
            (activityTypeChosen, completed:Bool, returnedItems:[Any]?, error:Error?) in
            if completed {
                self?.saveMeme(memedImage: memeImage)
                self?.dismiss(animated: true, completion: nil)
            }
        }
        self.present(activityController, animated: true, completion: nil)
    }
    
    func createMemedImage() -> UIImage {
        configureToolbars(hide: true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        configureToolbars(hide: false)
        return memedImage
    }
    func saveMeme(memedImage: UIImage) {
        // Not using this now but will in future
        _ = Meme(topText: topTextField.text ?? "", bottomText: bottomTextField.text ?? "", originalImage: mainImage.image ?? UIImage(), memeImage: memedImage)
    }
    
    //MARK: Keyboard functions
    //NOTE: If top text field is selected we don't want to move the view
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
            view.frame.origin.y = 0
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
        for textField in bothTextFields {
            textField.resignFirstResponder()
        }
        view.endEditing(true)
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for textField in bothTextFields {
            textField.resignFirstResponder()
        }
        view.endEditing(true)
    }
    func clearMeme() {
        self.mainImage.image = .none
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    func configureToolbars(hide: Bool) {
        for toolbar in bothToolbars {
            toolbar.isHidden = hide
        }
    }
    
}
