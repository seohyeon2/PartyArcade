//
//  GamePlayingViewController.swift
//  PartyArcade
//
//  Created by seohyeon park on 2022/10/05.
//

import UIKit

class GamePlayingViewController: UIViewController {

    @IBOutlet weak var currentQuestionLabel: UILabel!
    @IBOutlet weak var remainQuestionLabel: UILabel!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var answerInputTextField: UITextField!
    
    private var currentIndex = 0
    private var answerCount = 0
    
    @IBOutlet weak var mainStackViewBottomConstraint: NSLayoutConstraint!
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        if currentIndex == CurrentUserInfo.currentQuestions.count {
            return
        }
        var message = "틀림😑"
        if answerInputTextField.text == CurrentUserInfo.currentQuestions[currentIndex].answer {
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
            
            if self.currentIndex == CurrentUserInfo.currentQuestions.count {
                self.moveResultVC()
                return
            }
            
            self.currentQuestionLabel.text = "\(self.currentIndex + 1)번 문제"
            self.remainQuestionLabel.text = "총 문제: \(CurrentUserInfo.currentQuestions.count)"
        }
    }
    
    private func moveResultVC() {
        print("👍🏻 맞춘 문제 개수 : \(answerCount) ")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentQuestionLabel.text = "\(self.currentIndex + 1)번 문제"
        self.remainQuestionLabel.text = "총 문제: \(CurrentUserInfo.currentQuestions.count)"
        
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
