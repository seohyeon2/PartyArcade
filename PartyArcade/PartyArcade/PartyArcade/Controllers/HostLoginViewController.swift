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
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
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
        print(nicknameTextField.text)
        
        guard let nickname = nicknameTextField.text else { return }
        
        let user = UserInfo(
            name: nickname,
            uuid: UUID(),
            loginTime: Date().timeIntervalSince1970,
            isHost: CurrentUserInfo.isHost ?? false
        )
        
        CurrentUserInfo.userInfo = user
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
