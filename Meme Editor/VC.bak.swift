//
//  ViewController.swift
//  Meme Editor
//
//  Created by gem on 3/8/17.
//  Copyright © 2017 gem. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos


class VC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    // for image picker delegation
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet var imageView: UIImageView?
    @IBOutlet weak var topToolBar: UINavigationBar!
    
    // MARK: Actions
    @IBAction func clearAll(_ sender: Any) {
        self.imageView?.image = .none
        self.topTextField.text = ""
        self.bottomTextField.text = ""
    }
    @IBAction func saveImage(_ sender: Any) {
        // Remove placeholder text in case they want the meme to have a blank text field
        topTextField.placeholder = ""
        bottomTextField.placeholder = ""
        
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: (imageView?.image!)!, memeImage: textToMeme())
        
        // Life saver function!
        // found this on the udacity forums along with the callee - image:didFinishSavingWithError:contextInfo:
        UIImageWriteToSavedPhotosAlbum(meme.memeImage, self, #selector(saved(image:didFinishSavingWithError:contextInfo:)), nil)
        
        topTextField.placeholder = "Meme"
        bottomTextField.placeholder = "Me"
    }
    
    @IBAction func addImage(_ sender: Any) {
        let pickerViewController = ImagePickerController()
        pickerViewController.delegate = self
        pickerViewController.imageView?.image = self.imageView?.image
        present(pickerViewController, animated: true, completion: nil)
    }
    
    @IBAction func takePicture(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            //# TODO - ALERT CONTROLLER
            let alertController = UIAlertController()
            alertController.title = "Camera Not Found"
            print("NO CAMERA FOUND")
        }
    }
    
    @IBAction func shareImage(_ sender: Any) {
        
        let activity = self.textToMeme()
        let activityVC = UIActivityViewController(activityItems: [activity], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    
    func saved(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(title: "Success", message: "Image saved to Photo Album", preferredStyle: UIAlertControllerStyle.alert)
        
        // can use the dismiss button or implement time delay
        //let ok = UIAlertAction(title: "Ok", style: .default, handler: {action in self.dismiss(animated: true, completion: nil)})
        //alert.addAction(ok)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
            let delay = DispatchTime.now() + 0.7
            DispatchQueue.main.asyncAfter(deadline: delay, execute: {alert.dismiss(animated: true, completion: nil)})
        })
        
    }
    
    func searchAlbum() -> PHAssetCollection {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "Meme Me")
        let fetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
        guard let photoAlbum = fetchResult.firstObject else {
            let result = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary, options: nil)
            return result.firstObject!
        }
        return photoAlbum
    }
    
    private var count = 0
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView?.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    let pickerViewController = ImagePickerController()
    let contentMode = [UIViewContentMode.scaleAspectFit, UIViewContentMode.scaleToFill, UIViewContentMode.scaleAspectFill, UIViewContentMode.redraw, UIViewContentMode.center]
    
    func nextContentMode(swipe: UISwipeGestureRecognizer) {
        print(swipe.direction)
        switch swipe.direction.rawValue {
        // 1= right
        case 1:
            if let current = self.imageView?.contentMode {
                if let currentIndex = contentMode.index(of: current) {
                    // endIndex doesn't return index of last item, it returns the index after the last item
                    if currentIndex == contentMode.endIndex-1 {
                        self.imageView?.contentMode = contentMode[contentMode.startIndex]
                    } else {
                        self.imageView?.contentMode = contentMode[contentMode.index(after: contentMode.index(of: current)!)]
                    }
                }
                
            }
        case 2:
            if let current = self.imageView?.contentMode {
                if let currentIndex = contentMode.index(of: current) {
                    // endIndex doesn't return index of last item, it returns the index after the last item
                    if currentIndex == contentMode.startIndex {
                        self.imageView?.contentMode = contentMode[contentMode.index(before: contentMode.endIndex)]
                    } else {
                        self.imageView?.contentMode = contentMode[contentMode.index(before: contentMode.index(of: current)!)]
                    }
                }
                
            }
        default:
            return
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        topToolBar.isHidden = !topToolBar.isHidden
        bottomToolbar.isHidden = !bottomToolbar.isHidden
        
        view.endEditing(true)
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTextFields()
        pickerViewController.imageView = imageView
        topTextField.delegate = self
        bottomTextField.delegate = self
        bottomTextField.bindToKeyboard()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(nextContentMode))
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(nextContentMode))
        swipeRight.direction = .right
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeLeft)
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        //        view.addGestureRecognizer(tapGesture)
        // DOUBLE TAP
        //        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleBars))
        //        doubleTapGesture.numberOfTapsRequired = 2
        //        view.addGestureRecognizer(doubleTapGesture)
        view.isUserInteractionEnabled = true
        
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            self.cameraButton.isEnabled = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    func toggleBars(sender: AnyObject) {
        UIView.animate(withDuration: 2) {
            self.navigationController?.setToolbarHidden(true, animated: true)
            //            self.navigationController?.isNavigationBarHidden = self.navigationController?.isNavigationBarHidden == false
            // self.navigationController?.setNavigationBarHidden(self.navigationController?.isNavigationBarHidden == false, animated: false) // also works
        }
    }
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation{
        return UIStatusBarAnimation.slide
    }
    
    func hideKeyboard(){
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        view.endEditing(true)
    }
    // For pressing return on the keyboard to dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        return true
    }
    func textToMeme() -> UIImage{
        // TODO: Hide toolbar and navbar
        self.topToolBar.isHidden = true
        self.bottomToolbar.isHidden = true
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        self.topToolBar.isHidden = false
        self.bottomToolbar.isHidden = false
        return memedImage
    }
    
    func setupTextFields(){
        
        // to get centered text you need to create paragraphstyle object
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let memeTextStyle:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "StarJedi", size: 32)!,
            NSParagraphStyleAttributeName: paragraphStyle,
            NSStrokeWidthAttributeName: 10.0
        ]
        
        topTextField.defaultTextAttributes = memeTextStyle
        //topTextField.defaultTextAttributes[NSParagraphStyleAttributeName] = NSTextAlignment.center
        bottomTextField.defaultTextAttributes = memeTextStyle
        
        
    }
    
}


extension UIView {
    func bindToKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(UIView.keyboardWillChange(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    
    func keyboardWillChange(notification: NSNotification) {
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curFrame.origin.y
        
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y+=deltaY
            
        },completion: nil)
        
    }
}

