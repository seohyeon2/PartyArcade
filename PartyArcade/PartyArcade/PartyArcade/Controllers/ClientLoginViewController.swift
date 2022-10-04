//
//  ClientLoginViewController.swift
//  PartyArcade
//
//  Created by LeeChiheon on 2022/10/04.
//

import UIKit
import FirebaseDatabase

class ClientLoginViewController: UIViewController {

    // MARK: - Properties
    
    let myConnectionsRef = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()

    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.isEnabled = false
        nicknameTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Button Actions
    
    @IBAction func connectButtonTapped(_ sender: UIButton) {
        guard let nickname = nicknameTextField.text else { return }
        
        let user = UserInfo(
            name: nickname,
            uuid: UUID(),
            loginTime: Date().timeIntervalSince1970,
            isHost: CurrentUserInfo.isHost ?? false
        )
        
        CurrentUserInfo.userInfo = user
        
        
        guard let game = CurrentUserInfo.currentGame,
              let currentUserInfo = CurrentUserInfo.userInfo else { return }
        
        guard let inviteCode = CurrentUserInfo.currentRoom?.uuidString else { return }
        
        guard let encodedData = try? JSONEncoder().encode(currentUserInfo),
              let jsonData = try? JSONSerialization.jsonObject(with: encodedData) else { return }
        
        myConnectionsRef
            .child("rooms")
            .child(inviteCode)
            .child("userList")
            .child(currentUserInfo.uuid.uuidString)
            .setValue(jsonData)
        myConnectionsRef
            .child("rooms")
            .child(inviteCode)
            .child("userList")
            .child(currentUserInfo.uuid.uuidString)
            .onDisconnectRemoveValue()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // MARK: - keyboard Action
    
    @objc func keyboardUp(notification: NSNotification) {
        if let keyboardFrame:NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
           let keyboardRectangle = keyboardFrame.cgRectValue
       
            UIView.animate(
                withDuration: 0.3
                , animations: {
//                    self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
                    self.view.transform = CGAffineTransform(translationX: 0, y: -(self.loginButton.frame.origin.y / 2))
                }
            )
        }
    }
    
    @objc func keyboardDown() {
        self.view.transform = .identity
    }
}

// MARK: - UITextFieldDelegate

extension ClientLoginViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print(textField.text)
        
        if textField.text == "" {
            loginButton.isEnabled = false
        } else {
            loginButton.isEnabled = true
        }
    }
}
