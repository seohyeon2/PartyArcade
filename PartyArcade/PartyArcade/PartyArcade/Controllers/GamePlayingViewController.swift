//
//  GamePlayingViewController.swift
//  PartyArcade
//
//  Created by seohyeon park on 2022/10/05.
//

import UIKit
import FirebaseDatabase
import FirebaseSharedSwift

class GamePlayingViewController: UIViewController {

    let myConnectionsRef = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()

    
    @IBOutlet weak var currentQuestionLabel: UILabel!
    @IBOutlet weak var remainQuestionLabel: UILabel!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var answerInputTextField: UITextField!
    
    private var currentIndex = 0
    private var answerCount = 0
    private var currentQuestions: [GameQuestion]?
    
    @IBOutlet weak var mainStackViewBottomConstraint: NSLayoutConstraint!
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard let currentQuestions = currentQuestions else { return }
        if currentIndex == currentQuestions.count {
            return
        }
        var message = "틀림😑"
        if answerInputTextField.text == currentQuestions[currentIndex].answer {
            answerCount += 1
            message = "정답🥳"
        }
        showAlert(message: message)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: true)
            self.currentIndex += 1
            self.answerInputTextField.text = ""
            
            guard let currentQuestions = self.currentQuestions else { return }
            
            if self.currentIndex == currentQuestions.count {
                self.moveResultVC()
                return
            }
            
            self.currentQuestionLabel.text = "\(self.currentIndex + 1)번 문제"
            self.remainQuestionLabel.text = "총 문제: \(currentQuestions.count)"
        }
    }
    
    private func moveResultVC() {
        print("👍🏻 맞춘 문제 개수 : \(answerCount) ")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myConnectionsRef
            .child("rooms")
            .child(CurrentUserInfo.currentRoom!.uuidString)
            .child("userList")
            .getData { error, dataSnapshot in
                self.currentQuestions = try? FirebaseDataDecoder().decode(GameQuestions.self, from: dataSnapshot?.value).questions
                
//                CurrentUserInfo.currentQuestions = gameQuestions!.questions
                guard let currentQuestions = self.currentQuestions else { return }
                self.currentQuestionLabel.text = "\(self.currentIndex + 1)번 문제"
                self.remainQuestionLabel.text = "총 문제: \(currentQuestions.count)"
            }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewMoveUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewMoveDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func textViewMoveUp(_ notification: NSNotification){
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.3, animations: {
                self.mainStackViewBottomConstraint.constant = keyboardSize.height + 10
                self.view.layoutIfNeeded()
            })
            
        }
    }
    
    @objc func textViewMoveDown(_ notification: NSNotification){
        UIView.animate(withDuration: 0.3, animations: {
            self.mainStackViewBottomConstraint.constant = 80
            self.view.layoutIfNeeded()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
