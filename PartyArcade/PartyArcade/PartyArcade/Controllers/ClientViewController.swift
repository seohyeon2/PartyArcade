//
//  ClientViewController.swift
//  PartyArcade
//
//  Created by LeeChiheon on 2022/10/04.
//

import UIKit
import FirebaseDatabase

class ClientViewController: UIViewController {

    let myConnectionsRef = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    @IBOutlet weak var inviteCodeTextLabel: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        joinButton.isEnabled = false
        inviteCodeTextLabel.delegate = self
    }

    @IBAction func joinButtonTapped(_ sender: UIButton) {
        print(inviteCodeTextLabel.text)
        guard let inputedCode = inviteCodeTextLabel.text else { return }
        myConnectionsRef
            .child("rooms")
            .child(inputedCode)
            .getData { error, dataSnapshot in
                if error != nil {
                    print(error)
                    return
                }
                
                guard dataSnapshot!.exists() else {
                    print("방이 없음")
                    return
                }
                
                print("방 찾음")
                
                var zxc: Room? = nil
                do {
                    let asd = try JSONSerialization.data(withJSONObject: dataSnapshot!.value)
                    zxc = try JSONDecoder().decode(Room.self, from: asd)
                } catch {
                    print(error)
                }
                
                guard let game = Game(rawValue: zxc!.game.rawValue) else { return }
                CurrentUserInfo.currentGame = game
                CurrentUserInfo.currentRoom = UUID(uuidString: inputedCode)
                
                self.performSegue(withIdentifier: "moveToClientLoginView", sender: sender)
            }
    }
}

extension ClientViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        print(textField.text)
        
        if textField.text == "" {
            joinButton.isEnabled = false
        } else {
            joinButton.isEnabled = true
        }
    }
}
