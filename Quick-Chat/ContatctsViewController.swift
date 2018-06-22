//
//  ContatctsViewController.swift
//  QuickChat
//
//  Created by Ivan Divljak on 6/22/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import UIKit
import Firebase

protocol ContatsDialogDelegate: NSObjectProtocol {
    
    func selected(user: User)
    
    func contactsDialogDismissed()
    
}

class ContatctsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var items = [User]()
    weak var delegate: ContatsDialogDelegate?
    fileprivate let itemsPerRow: CGFloat = 3
    fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(UINib(nibName: String(describing: ContactsCollectionViewCell.self), bundle: nil),
                                     forCellWithReuseIdentifier: String(describing: ContactsCollectionViewCell.self))
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let label = UILabel(frame: self.collectionView.frame)
        label.text = "Seems like you're alone in this world"
        label.textAlignment = .center
        self.collectionView.backgroundView = label

        fetchUsers()
        // Do any additional setup after loading the view.
    }
    @IBAction func dismissClicked(_ sender: Any) {
        delegate?.contactsDialogDismissed()
        self.dismiss(animated: true, completion: nil)
    }
    //Downloads users list for Contacts View
    func fetchUsers() {
        if let id = Auth.auth().currentUser?.uid {
            UserRemoteRepository.downloadAllUsers(exceptID: id, completion: { user in
                DispatchQueue.main.async {
                    self.items.append(user)
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
}

extension ContatctsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            //2
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: widthPerItem)
        }
    
        //3
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
            return sectionInsets
        }
    
        // 4
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return sectionInsets.left
        }
    
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            collectionView.backgroundView?.isHidden = items.isEmpty ? false : true
            return self.items.count
        }
    
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ContactsCollectionViewCell.self),
                                                                    for: indexPath) as? ContactsCollectionViewCell else {
                                                                        return UICollectionViewCell()
                }
                cell.profilePic.image = self.items[indexPath.row].profilePic
                cell.nameLabel.text = self.items[indexPath.row].name
                cell.profilePic.layer.borderWidth = 2
                cell.profilePic.layer.borderColor = GlobalVariables.red.cgColor
                return cell
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if !self.items.isEmpty {
                self.dismiss(animated: true, completion: nil)
                delegate?.selected(user: self.items[indexPath.row])
            }
        }
}
