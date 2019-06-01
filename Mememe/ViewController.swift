//
//  ViewController.swift
//  Mememe
//
//  Created by Heeral on 12/11/18.
//  Copyright © 2018 heeral. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    
    let textDelegate = TextFieldDelegate()
   
    //setting the default textfield properties
    func resetTextField(textField: UITextField, text: String)
    {
        textField.defaultTextAttributes = [ NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeColor.rawValue): UIColor.black, NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white, NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!, NSAttributedString.Key(rawValue: NSAttributedString.Key.strokeWidth.rawValue): -4.0]
        
        textField.textAlignment = .center
        textField.text = text
        textField.textColor = UIColor.white
        textField.tintColor = UIColor.white
        textField.delegate = textDelegate
    }
    
    //setting the default properties
    func resetViewState()
    {
        imagePickerView.image = nil
        shareButton.isEnabled = false
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        resetTextField(textField: topTextField, text: "TOP")
        resetTextField(textField: bottomTextField, text: "BOTTOM")
        resetViewState()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
    }
    
    // MARK: subscribe keyboard. To Know when keyboard appears
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
       // cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        //show share button
        if imagePickerView.image == nil
        {
            shareButton.isEnabled = false
        }
        else
        {
            shareButton.isEnabled = true
        }
    }
    
    func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType)
    {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any)
    {
        
        // To see if the image got selected
        
        chooseImageFromCameraOrPhoto(source: .photoLibrary)
    }
    
    // To get image from Camera
    @IBAction func pickAnImageFromCamera(_ sender: Any)
    {
        chooseImageFromCameraOrPhoto(source: .camera)
    }
    
    // TO get access to the image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imagePickerView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
         picker.dismiss(animated: true, completion: nil)
    }
   
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications()
    {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
   
    @objc func keyboardWillShow(_ notification:Notification)
    {
        if textDelegate.currentField == bottomTextField
        {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification)
    {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat
    {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    // Initializing the memeModel Object
    func save(memedImage: UIImage)
    {
        // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: memedImage)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        dismiss(animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage
    {
        navigationController?.isToolbarHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        
        // Create a rect from imageView container view bounds
        let rect: CGRect = imageContainer.bounds
        let scale = memedImage.scale
        let scaledRect = CGRect(x: imageContainer.frame.origin.x * scale, y: imageContainer.frame.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        
        // Crop captured screen with rect created above and return just the contents of the image container view
        if let cgImage = memedImage.cgImage?.cropping(to: scaledRect) {
            let temp: UIImage = UIImage(cgImage: cgImage, scale: scale, orientation: .up)
            return temp
        } else {
            return memedImage
        }
    }
    
    @IBAction func sharedPressed(_ sender: Any)
    {
        let Image = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems: [Image], applicationActivities: nil)
        activityVC.popoverPresentationController?.barButtonItem = shareButton
        self.present(activityVC, animated: true, completion: nil)
        activityVC.completionWithItemsHandler =
            {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if (completed)
            {
                self.save(memedImage: Image)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem)
    {
        resetTextField(textField: topTextField, text: "TOP")
        resetTextField(textField: bottomTextField, text: "BOTTOM")
        resetViewState()
        
        self.dismiss(animated: true, completion: nil)
    }
}

