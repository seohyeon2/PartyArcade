//
//  LoginViewController.swift
//  PartyAracade
//
//  Created by LeeChiheon on 2022/10/03.
//

import UIKit
import FirebaseDatabase

class HostLoginViewController: UIViewController {

    // MARK: - Properties
    
    let database = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    let connectedRef = Database.database().reference(withPath: ".info/connected")
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    let imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        
        return imagePickerController
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentImagePickerController))
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        profileImage.clipsToBounds = true
        profileImage.layer.borderWidth = 10
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.layer.borderColor = UIColor.black.cgColor
        
        imagePickerController.delegate = self
        
        
        loginButton.isEnabled = false
        nicknameTextField.delegate = self
    }

    @objc func presentImagePickerController() {
        present(imagePickerController, animated: true)
    }
    
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        print(nicknameTextField.text)
        
        guard let nickname = nicknameTextField.text else { return }
        
        let user = UserInfo(
            name: nickname,
            uuid: UUID(),
            loginTime: Date().timeIntervalSince1970,
            isHost: CurrentUserInfo.isHost ?? false
        )
        
        CurrentUserInfo.userInfo = user
        
//        let encodedData = try! JSONEncoder().encode(user)
//        let jsonData = try! JSONSerialization.jsonObject(with: encodedData)
        
//        myConnectionsRef.child("connections").child(user.uuid.uuidString).setValue(jsonData)
//        myConnectionsRef.child("connections").child(user.uuid.uuidString).onDisconnectRemoveValue()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension HostLoginViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print(textField.text)
        
        if textField.text == "" {
            loginButton.isEnabled = false
        } else {
            loginButton.isEnabled = true
        }
    }
}

extension HostLoginViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print(info)
        profileImage.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        dismiss(animated: true)
    }
}
