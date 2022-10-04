//
//  ClientLoginViewController.swift
//  PartyArcade
//
//  Created by LeeChiheon on 2022/10/04.
//

import UIKit
import FirebaseDatabase

class ClientLoginViewController: UIViewController {

    let myConnectionsRef = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()

    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.isEnabled = false
        nicknameTextField.delegate = self
    }
    
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
        
        let encodedData = try! JSONEncoder().encode(currentUserInfo)
        let jsonData = try! JSONSerialization.jsonObject(with: encodedData)
        
        myConnectionsRef
            .child("rooms")
            .child(inviteCode)
            .child(game.string)
            .child(currentUserInfo.uuid.uuidString)
            .setValue(jsonData)
        myConnectionsRef
            .child("rooms")
            .child(inviteCode)
            .child(game.string)
            .child(currentUserInfo.uuid.uuidString)
            .onDisconnectRemoveValue()
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
    }
}

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
