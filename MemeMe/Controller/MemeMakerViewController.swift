//
//  MemeMakerViewController.swift
//  MemeMe
//
//  Created by Mustafa on 28/10/19.
//  Copyright © 2019 Mustafa Nafie. All rights reserved.
//

import UIKit

class MemeMakerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
	
	// MARK: Outlets
	
	@IBOutlet weak var imagePickerView: UIImageView!
	@IBOutlet weak var cameraButton: UIBarButtonItem!
	@IBOutlet weak var topTextField: UITextField!
	@IBOutlet weak var bottomTextField: UITextField!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var toolbar: UIToolbar!
	@IBOutlet weak var navbar: UINavigationBar!
	@IBOutlet weak var saveButton: UIBarButtonItem!
	
	// MARK: Properties
	
	var currentTappedTextField: UITextField?
	let memeTextAttributes: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.strokeColor: UIColor.black,
		NSAttributedString.Key.foregroundColor: UIColor.white,
		NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
		NSAttributedString.Key.strokeWidth: -3,
	]
	
	// MARK: Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		// Setup the textfields
		topTextField.text = "TOP"
		topTextField.defaultTextAttributes = memeTextAttributes
		topTextField.textAlignment = .center
		topTextField.delegate = self
		bottomTextField.text = "BOTTOM"
		bottomTextField.defaultTextAttributes = memeTextAttributes
		bottomTextField.textAlignment = .center
		bottomTextField.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		// Disable the camera button if the device doesn't have a camera
		cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
		// Subscribe to Keyboard notifications, to move the view when keyboard shows
		subscribeToKeyboardNotifications()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		// Unsubscribe from Keyboard notifications
		unsubscribeFromKeyboardNotifications()
	}
	
	// MARK: Actions
	
	@IBAction func pickAnImageFromCamera(_ sender: Any) {
		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self
		imagePickerController.sourceType = .camera
		present(imagePickerController, animated: true, completion: nil)
	}
	
	@IBAction func pickAnImageFromAlbum(_ sender: Any) {
		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self
		imagePickerController.sourceType = .photoLibrary
		present(imagePickerController, animated: true, completion: nil)
	}
	
	@IBAction func activityView(_ sender: Any) {
		let memedImage = generateMemedImage()
		let shareActivityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
		
		shareActivityViewController.completionWithItemsHandler = { activity, completed, items, error in
			if completed {
				// Save the image
				self.save(memedImage: memedImage)
				// Dismiss the shareActivityViewController
				self.dismiss(animated: true, completion: nil)
			}
		}
		
		self.present(shareActivityViewController, animated: true, completion: nil)
	}
	
	// MARK: TextField Methods
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		// Check which textfield is tapped
		currentTappedTextField = textField
		// Clear default text when the user starts editing
		if textField.text == "TOP" || textField.text == "BOTTOM" {
			textField.text = ""
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		// Rewrite TOP and BOTTOM if the user didn't change the text
		if textField.text == "" && currentTappedTextField == topTextField {
			textField.text = "TOP"
		} else if textField.text == "" && currentTappedTextField == bottomTextField {
			textField.text = "BOTTOM"
		}
		// Dismiss the keyboard when the user presses enter
		textField.resignFirstResponder()
		return true
	}
	
	// MARK: Keyboard Methods
	
	@objc func keyboardWillShow(_ notification:Notification) {
		// Move the view up when the bottom textfield is tapped
		if currentTappedTextField == bottomTextField {
			view.frame.origin.y -= getKeyboardHeight(notification)
		}
	}
	
	@objc func keyboardWillHide(_ notification:Notification) {
		// Move the view back down
		view.frame.origin.y = 0
	}
	
	func getKeyboardHeight(_ notification:Notification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.cgRectValue.height
	}
	
	func subscribeToKeyboardNotifications() {
		// Subscribe to keyboardWillShowNotification
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		// Subscribe to keyboardWillHideNotification
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	func unsubscribeFromKeyboardNotifications() {
		// Unsubscribe from keyboardWillShowNotification
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		// Unsubscribe from keyboardWillHideNotification
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	// MARK: ImagePicker Methods
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
			imagePickerView.image = image
			saveButton.isEnabled = true
		}
		dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true, completion: nil)
	}
	
	// MARK: Meme Methods
	
	func generateMemedImage() -> UIImage {
		// Hide toolbar and navbar
		toolbar.isHidden = true
		navbar.isHidden = true
		// Render view to an image
		UIGraphicsBeginImageContext(self.view.frame.size)
		view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
		let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		// Show toolbar and navbar
		toolbar.isHidden = false
		navbar.isHidden = false
		
		return memedImage
	}
	
	func save(memedImage: UIImage) {
		// Create the meme
		let meme = Meme(topText: topTextField.text! as NSString?, bottomText: bottomTextField.text! as NSString?,  image: imagePickerView.image, memedImage: memedImage)
		// Add it to the memes array in the Application Delegate
		(UIApplication.shared.delegate as! AppDelegate).memes.append(meme)
	}
	
}
