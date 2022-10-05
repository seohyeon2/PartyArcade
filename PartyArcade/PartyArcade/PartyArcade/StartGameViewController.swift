//
//  StartGameViewController.swift
//  PartyArcade
//
//  Created by seohyeon park on 2022/10/05.
//

import UIKit
import FirebaseDatabase
import FirebaseSharedSwift

class StartGameViewController: UIViewController {
    let database = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()

    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var answerInputTextField: UITextField!
    
    private var currentIndex = 0
    private var answerCount = 0
    private var questions = [GameQuestion]()
    
    @IBAction func didTapSubmitButton(_ sender: UIButton) {
        print(currentIndex, questions.count)
        if currentIndex == questions.count {
            return
        }
        var message = "틀림😑"
        if answerInputTextField.text == questions[currentIndex].answer {
            answerCount += 1
            message = "정답🥳"
        }
        showAlert(message: message)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//        let height:NSLayoutConstraint = NSLayoutConstraint(
//            item: alert.view!,
//            attribute: NSLayoutConstraint.Attribute.height,
//            relatedBy: NSLayoutConstraint.Relation.equal,
//            toItem: nil,
//            attribute: NSLayoutConstraint.Attribute.notAnAttribute,
//            multiplier: 1,
//            constant: 500
//        )
//       alert.view.addConstraint(height)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: true)
            self.currentIndex += 1
            self.answerInputTextField.text = ""
            
            if self.currentIndex == self.questions.count {
                self.moveResultVC()
            }
        }
    }
    
    private func moveResultVC() {
        guard let storyboard = storyboard,
              let resultVC = storyboard.instantiateViewController(
                withIdentifier: "ResultViewController"
              ) as? ResultViewController else {
            return
        }
        
        present(resultVC, animated: true)
    }
    
    private func settingGame() {
        let databaseTitle = "드라마"
        let randomNumbers = getRandomNumber(number: 5, total: 20)
        
        randomNumbers.forEach { number in
            database.child(databaseTitle).child("\(number)").getData { error, dataSnapshot in
                if let error = error {
                    print("\(error)")
                    return
                }

                guard let snapshot = dataSnapshot,
                      let value = snapshot.value,
                      let data = try? FirebaseDataDecoder().decode(GameQuestion.self, from: value) else {
                    print("decode fail")
                    return
                }
                
                self.questions.append(data)
                self.database.child("유저_\(databaseTitle)")
                    .child("\(self.questions.count-1)")
                    .setValue([
                        "data": "\(data.data)",
                        "answer": "\(data.answer)"
               ])
            }
        }
    }
    
    private func getRandomNumber(number: Int, total: Int) -> [Int] {
        guard number > 0 else {
            return [0]
        }
        
        var result = [Int]()
        while result.count < number {
            let randomNumber = Int.random(in: 0..<total)
            
            if result.contains(randomNumber) == false {
                result.append(randomNumber)
            }
        }
        
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingGame()
    }
}
