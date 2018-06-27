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
import SpriteKit

class WelcomeVC: BaseViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var registerEmailField: UITextField!
    @IBOutlet weak var registerNameField: UITextField!
    @IBOutlet weak var registerPasswordField: UITextField!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var profilePicView: RoundedImageView!
    
    @IBOutlet weak var signIn: UIButton!
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var register: UIButton!
    
    @IBOutlet weak var background2: UIImageView!
    @IBOutlet weak var background1: UIImageView!
    @IBOutlet weak var background3: UIImageView!
    
    var isLoginViewVisible = true
    var userUseCase: UserUseCaseProtocol!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        registerView.alpha = 0
        self.register.isHidden = false
        self.signIn.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        imagePicker.delegate = self
        
        let displayLink = CADisplayLink(target: self, selector: #selector(cloundsAnimation))
        displayLink.add(to: .main, forMode: .defaultRunLoopMode)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cloundsAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.layoutIfNeeded()
    }
    
    func customization() {
        signInView.layer.cornerRadius = 10
        registerView.layer.cornerRadius = 10
    }
   
    @objc func cloundsAnimation() {
        self.background1.frame = self.background1.frame.offsetBy(dx: -1, dy: 0.0)
        self.background2.frame = self.background2.frame.offsetBy(dx: -1, dy: 0.0)
        self.background3.frame = self.background3.frame.offsetBy(dx: -1, dy: 0.0)
        
        if background2.frame.minX == 0 {
            self.background1.frame = self.background1.frame.offsetBy(dx: self.background1.frame.width * 3, dy: 0.0)
        }
        
        if background3.frame.minX == 0 {
            self.background2.frame = self.background2.frame.offsetBy(dx: self.background2.frame.width * 3, dy: 0.0)
        }
        
        if background1.frame.minX == 0 {
            self.background3.frame = self.background3.frame.offsetBy(dx: self.background3.frame.width * 3, dy: 0.0)
        }
        
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
        self.startActivityIndicatorSpinner()
        userUseCase.loginUser(withEmail: emailText, password: passwordText) { [weak weakSelf = self] status in
            DispatchQueue.main.async {
                if status {
                    weakSelf?.pushTomainView()
                    self.stopActivityIndicatorSpinner()
                } else {
                    let ok = DialogWrapper(title: "OK", uiAction: .default, image: nil, handler: { _ in
                        
                    })
                    AlertUtility.showCustomDialog(self, choices: [ok], title: "Error", message: "Something happened, you cant log in")
                }
                self.stopActivityIndicatorSpinner()
                weakSelf = nil
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func createAccountClicked(_ sender: Any) {
        signInView.alpha = 1
        UIView.animate(withDuration: 0.5, animations: { self.signInView.alpha = 0 }, completion: { _ in self.registerView.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.registerView.alpha = 1
                self.register.isHidden = true
                self.signIn.isHidden = false }, completion: nil)
        })
    }
    @IBAction func signInClicked(_ sender: Any) {
        registerView.alpha = 1
        UIView.animate(withDuration: 0.5, animations: { self.registerView.alpha = 0 }, completion: { _ in self.signInView.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                self.signInView.alpha = 1
                self.register.isHidden = false
                self.signIn.isHidden = true }, completion: nil)
        })
    }
    @objc func dismissKeyboard () {
        self.view.endEditing(true)
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
        if let popoverController = sheet.popoverPresentationController {
            popoverController.sourceView = self.view
            print(chooseButton.frame)
            popoverController.sourceRect = CGRect(x: self.view.frame.width / 2,
                                                  y: chooseButton.frame.maxY + registerView.frame.minY,
                                                  width: 0, height: 0)
            popoverController.permittedArrowDirections = [UIPopoverArrowDirection.up]
        }
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
        self.view.isUserInteractionEnabled = false
        self.startActivityIndicatorSpinner()
        userUseCase.registerUser(withName: registerName, email: registerEmail,
                                          password: registerPassword, profilePic: image) { [weak weakSelf = self] status in
            DispatchQueue.main.async {
                if status {
                    guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "homeNavigation"),
                          let navigationController = viewController as? UINavigationController else {
                        return
                    }
                    self.view.isUserInteractionEnabled = true
                    self.show(navigationController, sender: nil)
                    self.stopActivityIndicatorSpinner()
                    weakSelf?.profilePicView.image = UIImage.init(named: "profile pic")
                } else {
                    self.view.isUserInteractionEnabled = true
                    let ok = DialogWrapper(title: "OK", uiAction: .default, image: nil, handler: { _ in
                        
                    })
                    self.stopActivityIndicatorSpinner()
                    AlertUtility.showCustomDialog(self, choices: [ok], title: "Error", message: "Something happened, you cant log in")
                }
            }
        }
    }
    
}
