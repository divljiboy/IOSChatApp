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
import Firebase
import CoreLocation

class ChatVC: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    let locationManager = CLLocationManager()
    var items = [Message]()
    let imagePicker = UIImagePickerController()
    let showLocationVRSegue = "showLocationVR"
    var currentUser: User?
    var canSendLocation = true
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    func customization() {
        self.imagePicker.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(UINib(nibName: String(describing: SenderTableViewCell.self), bundle: nil),
                                forCellReuseIdentifier: String(describing: SenderTableViewCell.self))
        self.tableView.register(UINib(nibName: String(describing: ReceiverTableViewCell.self), bundle: nil),
                                forCellReuseIdentifier: String(describing: ReceiverTableViewCell.self))
        self.navigationItem.title = self.currentUser?.name
        self.locationManager.delegate = self
    }
    
    //Downloads messages
    func fetchData() {
        guard let user = self.currentUser else {
            return
        }
        MessageRemoteRepository.downloadAllMessages(forUserID: user.id, completion: {[weak weakSelf = self] message in
            weakSelf?.items.append(message)
            weakSelf?.items.sort {
                $0.timestamp < $1.timestamp
            }
            DispatchQueue.main.async {
                if let state = weakSelf?.items.isEmpty, state == false {
                    weakSelf?.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
        })
        MessageRemoteRepository.markMessagesRead(forUserID: user.id)
    }
    
    //Hides current viewcontroller
    @objc func dismissSelf() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    func composeMessage(type: MessageType, content: Any) {
        guard let user = self.currentUser else {
            return
        }
        let message = Message.init(type: type, content: content, owner: .sender, timestamp: Int(Date().timeIntervalSince1970), isRead: false)
        MessageRemoteRepository.send(message: message, toID: user.id, completion: { _ in
        })
    }
    
    func checkLocationPermission() -> Bool {
        var state = false
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            state = true
        case .authorizedAlways:
            state = true
        default: break
        }
        return state
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showLocationVRSegue {
            guard let locationVRController = segue.destination as? LocationViewController,
                  let location = sender as? CLLocation else {
                return
            }
            locationVRController.pinLocation = CLLocation(latitude: 45.25539811893112, longitude: 19.79583130511105)
        }
    }
    
    @IBAction func selectGallery(_ sender: Any) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized || status == .notDetermined {
            self.imagePicker.sourceType = .savedPhotosAlbum
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func selectCamera(_ sender: Any) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if status == .authorized || status == .notDetermined {
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func selectLocation(_ sender: Any) {
        self.canSendLocation = true
        if self.checkLocationPermission() {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        if let text = self.inputTextField.text {
            if !text.isEmpty {
                guard let text = self.inputTextField.text else {
                    return
                }
                self.composeMessage(type: .text, content: text)
                self.inputTextField.text = ""
            }
        }
    }
    
    @objc func showKeyboard(notification: Notification) {
        
        guard let userInfo = (notification as NSNotification).userInfo else {
            return
        }
        let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
        let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
        if let height = endFrame?.size.height {
            self.bottomConstraint.constant = height
        }
        if !self.items.isEmpty {
            self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
        }
        
        UIView.animate(withDuration: duration,
                       delay: TimeInterval(0),
                       options: animationCurve,
                       animations: { self.view.layoutIfNeeded() },
                       completion: { _ in
                if !self.items.isEmpty {
                        self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                }
        })
        
    }
    
    @objc func hideKeyboard(notification: Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else {
            return
        }
        _ = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
        let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
        
        self.bottomConstraint.constant = 0
        
        UIView.animate(withDuration: duration,
                       delay: TimeInterval(0),
                       options: animationCurve,
                       animations: { self.view.layoutIfNeeded() },
                       completion: { _ in
                        if !self.items.isEmpty {
                            self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                        }
        })
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.items[indexPath.row].owner {
        case .receiver:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReceiverTableViewCell.self),
                                                           for: indexPath) as? ReceiverTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            cell.clearCellData()
            switch self.items[indexPath.row].type {
            case .text:
                guard let text = self.items[indexPath.row].content as? String else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Cell")
                }
                cell.message.text = text
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { state, _ in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                            }
                        }
                    })
                }
            case .location:
                cell.messageBackground.image = UIImage.init(named: "location")
                cell.message.isHidden = true
                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                }
            }
            return cell
        case .sender:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SenderTableViewCell.self), for: indexPath) as? SenderTableViewCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            cell.clearCellData()
            cell.profilePic.image = self.currentUser?.profilePic
            switch self.items[indexPath.row].type {
            case .text:
                guard let text = self.items[indexPath.row].content as? String else {
                    return UITableViewCell(style: .default, reuseIdentifier: "Cell")
                }
                cell.message.text = text
            case .photo:
                if let image = self.items[indexPath.row].image {
                    cell.messageBackground.image = image
                    cell.message.isHidden = true
                } else {
                    cell.messageBackground.image = UIImage.init(named: "loading")
                    self.items[indexPath.row].downloadImage(indexpathRow: indexPath.row, completion: { state, _ in
                        if state == true {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: false)
                            }
                        }
                    })
                }
            case .location:
                cell.messageBackground.image = UIImage.init(named: "location")
                cell.message.isHidden = true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.inputTextField.resignFirstResponder()
        switch self.items[indexPath.row].type {
        case .photo:
            if let photo = self.items[indexPath.row].image {
                let info = ["viewType": ShowExtraView.preview, "pic": photo] as [String: Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showExtraView"), object: nil, userInfo: info)
                self.inputAccessoryView?.isHidden = true
            }
        case .location:
            guard let text = self.items[indexPath.row].content as? String else {
                return
            }
            
            let coordinates = (text).components(separatedBy: ":")
            
            guard let latitude = CLLocationDegrees(coordinates[0]),
                  let longtitude = CLLocationDegrees(coordinates[1]) else {
                return
            }
            let location = CLLocation(latitude: latitude, longitude: longtitude)
            self.performSegue(withIdentifier: showLocationVRSegue, sender: location)
            self.inputAccessoryView?.isHidden = true
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.composeMessage(type: .photo, content: pickedImage)
        } else {
            guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                return
            }
            self.composeMessage(type: .photo, content: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        if let lastLocation = locations.last {
            if self.canSendLocation {
                let coordinate = String(lastLocation.coordinate.latitude) + ":" + String(lastLocation.coordinate.longitude)
                let message = Message.init(type: .location, content: coordinate, owner: .sender,
                                           timestamp: Int(Date().timeIntervalSince1970), isRead: false)
                guard let id = self.currentUser?.id else {
                    return
                }
                MessageRemoteRepository.send(message: message, toID: id, completion: { _ in
                    self.tableView.scrollToRow(at: IndexPath.init(row: self.items.count - 1, section: 0), at: .bottom, animated: true)
                })
                self.canSendLocation = false
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.layoutIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.showKeyboard(notification:)),
                                               name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.hideKeyboard(notification:)),
                                               name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let id = self.currentUser?.id else {
            return
        }
        MessageRemoteRepository.markMessagesRead(forUserID: id)
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        self.fetchData()
    }
}
