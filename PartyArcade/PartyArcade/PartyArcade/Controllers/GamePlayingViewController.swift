//
//  GamePlayingViewController.swift
//  PartyArcade
//
//  Created by seohyeon park on 2022/10/05.
//

import UIKit
import FirebaseDatabase
import FirebaseSharedSwift
import FirebaseStorage

class GamePlayingViewController: UIViewController {

    // MARK: - Properties
    
    let myConnectionsRef = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    let storageRef = Storage.storage(url:"gs://partyarcade-c914b.appspot.com").reference()

    
    @IBOutlet weak var currentQuestionLabel: UILabel!
    @IBOutlet weak var remainQuestionLabel: UILabel!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var answerInputTextField: UITextField!
    
    private var currentIndex = 0
    private var answerCount = 0
    private var currentQuestions: [GameQuestion]?
    
    @IBOutlet weak var mainStackViewBottomConstraint: NSLayoutConstraint!
    
    var timer: Timer?
    private var timerCount = 20
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myConnectionsRef
            .child("rooms")
            .child(CurrentUserInfo.currentRoom!.uuidString)
            .child("userList")
            .getData { error, dataSnapshot in
                self.currentQuestions = try? FirebaseDataDecoder().decode(GameQuestions.self, from: dataSnapshot?.value).questions
                
                guard let currentQuestions = self.currentQuestions else {
                    return
                }
                self.setUpImageView(name: currentQuestions[0].data)
                self.startTimer(count: 20) {
                    self.showAlert(message: "틀림") {
                        self.showNextQuestion()
                    }
                }
                
                guard let currentQuestions = self.currentQuestions else { return }
                self.currentQuestionLabel.text = "\(self.currentIndex + 1)번 문제"
                self.remainQuestionLabel.text = "총 문제: \(currentQuestions.count)"
            }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewMoveUp), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textViewMoveDown), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard let currentQuestions = currentQuestions else { return }
        var message = "틀림😑"
        if answerInputTextField.text == currentQuestions[currentIndex].answer {
            answerCount += 1
            message = "정답🥳"
        }
        
        if currentIndex >= currentQuestions.count - 1 {
            showAlert(message: message) {
                self.moveResultVC()
            }
            return
        }
        
        self.showAlert(message: message) {
            self.showNextQuestion()
        }
    }
    
    private func setUpImageView(name: String) {
        let imageRef = storageRef.child("\(name).png")
        
        imageRef.downloadURL { url, error in
            if let error = error {
                print("😎")
                print(error)
                return
            }
            
            guard let url = url else {
                print("🥶")
                return
            }

            DispatchQueue.global().async {
                guard let data = try? Data(contentsOf: url) else {
                    print("😱")
                    return
                }
                DispatchQueue.main.async {
                    self.questionImageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    private func showAlert(message: String, completion: @escaping (() -> Void)) {
        if UIApplication.topViewController() is GamePlayingViewController {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.dismiss(animated: true) {
                    completion()
                }
            }
        }
    }
    
    private func startTimer(count: Int, completion: @escaping (() -> Void)) {
        var timerCount = count
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
            
            if timerCount > 0 {
                print(timerCount)
                timerCount -= 1
                self.timerLabel.text = "⏰ \(timerCount)"
            } else {
                self.stopTimer(setTimerLabel: 20)
                completion()
            }
        })
    }
    
    private func stopTimer(setTimerLabel: Int) {
        self.timerLabel.text = "⏰ \(setTimerLabel)"
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func showNextQuestion() {
        self.stopTimer(setTimerLabel: 20)
        guard let currentQuestions = self.currentQuestions else { return }
        
        if self.currentIndex > currentQuestions.count - 1 {
            self.moveResultVC()
            return
        }
        
        self.currentIndex += 1
        self.setUpImageView(name: currentQuestions[currentIndex].data)
        self.answerInputTextField.text = ""
        
        self.startTimer(count: 20) {
            self.showAlert(message: "틀림") {
                self.showNextQuestion()
            }
        }
        
        self.currentQuestionLabel.text = "\(self.currentIndex + 1)번 문제"
        self.remainQuestionLabel.text = "총 문제: \(currentQuestions.count)"
    }
    
    private func moveResultVC() {
        myConnectionsRef
            .child("rooms")
            .child(CurrentUserInfo.currentRoom!.uuidString)
            .child("answerList")
            .child(CurrentUserInfo.userInfo?.uuid.uuidString ?? "")
            .setValue([CurrentUserInfo.userInfo?.name: answerCount])
        
        performSegue(withIdentifier: "moveToResult", sender: nil)
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
