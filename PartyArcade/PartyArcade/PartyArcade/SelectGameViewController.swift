//
//  SelectGameViewController.swift
//  PartyArcade
//
//  Created by seohyeon park on 2022/10/05.
//

import UIKit
import FirebaseDatabase
import FirebaseSharedSwift

struct GameQuestion: Codable {
    let answer, data: String
}

class SelectGameViewController: UIViewController {
    let database = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    private let titles = [
        "사진보고 제목 맞추기☺️",
        "사진보고 인물 맞추기☺️",
        "앞글자 보고 이어 말하기☺️"
    ]
    
    private let buttonTitle = [
        ["드라마", "영화"],
        ["한국", "외국"],
        ["네글자", "속담"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for i in 0...20 {
//            database.child("드라마").child("\(i)").setValue([
//                "data": "문제\(i)",
//                "answer": "정답\(i)",
//            ])
//        }
    }
    
    private var questions = [GameQuestion]()
    
    @IBAction func didTapButton(_ sender: UIButton) {
        guard let databaseTitle = sender.currentTitle else {
            return
        }
        

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
                        "answer": "\(data.answer)",
                        "playerAnswer": ""
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
}

extension SelectGameViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SelectGameCell",
            for: indexPath
        ) as? SelectGameCell else {
            return UICollectionViewCell()
        }
        
        
        cell.titleLabel.text = titles[indexPath.row]
        cell.firstGameButton.setTitle(buttonTitle[indexPath.row].first, for: .normal)
        cell.secondGameButton.setTitle(buttonTitle[indexPath.row].last, for: .normal)
        return cell
    }
}

class SelectGameCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstGameButton: UIButton!
    @IBOutlet weak var secondGameButton: UIButton!
}
