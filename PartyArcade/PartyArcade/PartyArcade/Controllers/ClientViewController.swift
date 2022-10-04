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
                
                guard let dataSnapshot = dataSnapshot else {
                    return
                }
                
                print(dataSnapshot)
                print("방 찾음")
                
                guard let aaa = dataSnapshot.value as? [String: [String: [String: Any]]] else { return }
                
                guard let game = aaa.keys.first else { return }
                
                var currentGame: Game
                switch game.description {
                case "drama":
                    currentGame = .Drama
                case "movie":
                    currentGame = .Movie
                default:
                    currentGame = .Drama
                }
                
                CurrentUserInfo.currentGame = currentGame
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
