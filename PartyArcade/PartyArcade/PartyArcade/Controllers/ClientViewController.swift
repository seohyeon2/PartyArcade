//
//  ClientViewController.swift
//  PartyArcade
//
//  Created by LeeChiheon on 2022/10/04.
//

import UIKit
import FirebaseDatabase
import FirebaseSharedSwift

class ClientViewController: UIViewController {

    // MARK: - Properties
    
    let myConnectionsRef = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    @IBOutlet weak var inviteCodeTextLabel: UITextField!
    @IBOutlet weak var joinButton: UIButton!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        joinButton.isEnabled = false
        inviteCodeTextLabel.delegate = self
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
                
                guard let dataSnapshotExists = dataSnapshot?.exists(),
                      dataSnapshotExists else {
                    self.showAlert(message: "방이 없어요")
                    return
                }
                
                print("방 찾음")
                
                guard let room = try? FirebaseDataDecoder().decode(Room.self, from: dataSnapshot?.value) else { return }

                guard room.isPlaying == false else {
                    self.showAlert(message: "게임이 이미 진행중이에요")
                    return
                }
                
                guard let game = Game(rawValue: room.game.rawValue) else { return }
                CurrentUserInfo.currentGame = game
                CurrentUserInfo.currentRoom = UUID(uuidString: inputedCode)
                
                self.performSegue(withIdentifier: "moveToClientLoginView", sender: sender)
            }
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
                    self.view.transform = CGAffineTransform(translationX: 0, y: -(self.joinButton.frame.origin.y / 2))
                }
            )
        }
    }
    
    @objc func keyboardDown() {
        self.view.transform = .identity
    }

    // MARK: - Methods
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.dismiss(animated: true) {
                completion?()
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate

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
