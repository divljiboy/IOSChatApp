//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import Photos

class WelcomeVC: BaseViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var registerEmailField: UITextField!
    @IBOutlet weak var registerNameField: UITextField!
    @IBOutlet weak var registerPasswordField: UITextField!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var profilePicView: RoundedImageView!
    
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var cloudsView: UIImageView!
    @IBOutlet weak var cloudsViewLeading: NSLayoutConstraint!
    @IBOutlet weak var register: UIButton!
    
    var isLoginViewVisible = true
    let imagePicker = UIImagePickerController()
    
    func customization() {
        signInView.layer.cornerRadius = 10
        registerView.layer.cornerRadius = 10
    }
   
    func cloundsAnimation() {
        let distance = self.view.bounds.width - self.cloudsView.bounds.width
        self.cloudsViewLeading.constant = distance
        UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func pushTomainView() {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "homeNavigation") as? UINavigationController else {
            return
        }
        self.show(viewController, sender: nil)
    }

    @IBAction func login(_ sender: Any) {
        guard let emailText = self.loginEmailField.text,
            let passwordText = self.loginPasswordField.text else {
                return
        }
        UserRemoteRepository.loginUser(withEmail: emailText, password: passwordText) { [weak weakSelf = self] status in
            DispatchQueue.main.async {
                if status {
                    weakSelf?.pushTomainView()
                } else {
                    let ok = DialogWrapper(title: "OK", uiAction: .default, image: nil, handler: { _ in
                        
                    })
                    
                    ViewUtility.showCustomDialog(self, choices: [ok], title: "Error", message: "Something happened, you cant log in")
                }
                weakSelf = nil
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        registerView.alpha = 0
        self.register.isHidden = false
        self.signIn.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    @IBAction func createAccountClicked(_ sender: Any) {
        signInView.alpha = 1
        UIView.animate(withDuration: 0.5, animations: { self.signInView.alpha = 0 }) { _ in self.registerView.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.registerView.alpha = 1
                self.register.isHidden = true
                self.signIn.isHidden = false }, completion: nil)
        }
    }
    @IBAction func signInClicked(_ sender: Any) {
        registerView.alpha = 1
        UIView.animate(withDuration: 0.5, animations: { self.registerView.alpha = 0 }) { _ in self.signInView.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.signInView.alpha = 1
                self.register.isHidden = false
                self.signIn.isHidden = true }, completion: nil)
        }
    }
    @objc func dismissKeyboard () {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cloundsAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cloudsViewLeading.constant = 0
        self.cloudsView.layer.removeAllAnimations()
        self.view.layoutIfNeeded()
    }
    @IBAction func selectPic(_ sender: Any) {
        let sheet = UIAlertController(title: nil, message: "Select the source", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { _ -> Void in
            self.openPhotoPickerWith(source: .camera)
        })
        let photoAction = UIAlertAction(title: "Gallery", style: .default, handler: { _ -> Void in
            self.openPhotoPickerWith(source: .library)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cameraAction)
        sheet.addAction(photoAction)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profilePicView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func openPhotoPickerWith(source: PhotoSource) {
        switch source {
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            if  status == .authorized || status == .notDetermined {
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        case .library:
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .authorized || status == .notDetermined {
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func register(_ sender: Any) {
        guard let registerName = self.registerNameField.text,
            let registerEmail = self.registerEmailField.text,
            let registerPassword = self.registerPasswordField.text,
            let image = self.profilePicView.image else {
                return
        }
        UserRemoteRepository.registerUser(withName: registerName, email: registerEmail,
                                          password: registerPassword, profilePic: image) { [weak weakSelf = self] status in
            DispatchQueue.main.async {
                if status {
                    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Navigation") as? UINavigationController else {
                        return
                    }
                    self.show(viewController, sender: nil)
                    weakSelf?.profilePicView.image = UIImage.init(named: "profile pic")
                } else {
                    let ok = DialogWrapper(title: "OK", uiAction: .default, image: nil, handler: { _ in
                        
                    })
                    
                    ViewUtility.showCustomDialog(self, choices: [ok], title: "Error", message: "Something happened, you cant log in")
                }
            }
        }
    }
    
}
