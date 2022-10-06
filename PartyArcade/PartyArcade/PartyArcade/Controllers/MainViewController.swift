//
//  MainViewController.swift
//  PartyArcade
//
//  Created by LeeChiheon on 2022/10/04.
//

import UIKit
import FirebaseDatabase
import FirebaseSharedSwift

enum Game: Int, Codable {
    case Drama = 0
    case Movie
    
    var string: String {
        switch self {
        case .Drama:
            return "drama"
        case .Movie:
            return "movie"
        }
    }
    
    var koreanString: String {
        switch self {
        case .Drama:
            return "드라마"
        case .Movie:
            return "영화"
        }
    }
}

class MainViewController: UIViewController {

    let myConnectionsRef = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func gameButtonTapped(_ sender: UIButton) {
        
        guard let game = Game(rawValue: sender.tag),
              let currentUserInfo = CurrentUserInfo.userInfo else { return }
        
        let inviteCode = UUID()
        CurrentUserInfo.currentGame = game
        CurrentUserInfo.currentRoom = inviteCode
        
        guard let encodedData = try? JSONEncoder().encode(currentUserInfo),
              let jsonData = try? JSONSerialization.jsonObject(with: encodedData) else { return }
        
        myConnectionsRef
            .child("rooms")
            .child(inviteCode.uuidString)
            .child("game")
            .setValue(game.rawValue)
//        myConnectionsRef
//            .child("rooms")
//            .child(inviteCode.uuidString)
//            .child("game")
//            .onDisconnectRemoveValue()
        
        myConnectionsRef
            .child("rooms")
            .child(inviteCode.uuidString)
            .child("isPlaying")
            .setValue(false)
//        myConnectionsRef
//            .child("rooms")
//            .child(inviteCode.uuidString)
//            .child("isPlaying")
//            .onDisconnectRemoveValue()
                
        myConnectionsRef
            .child("rooms")
            .child(inviteCode.uuidString)
            .child("userList")
            .child(currentUserInfo.uuid.uuidString)
            .setValue(jsonData)
        myConnectionsRef
            .child("rooms")
            .child(inviteCode.uuidString)
            .child("userList")
            .child(currentUserInfo.uuid.uuidString)
            .onDisconnectRemoveValue()
        
        
        
        let randomNumbers = getRandomNumber(number: 5, total: 20)
        var currentQuestions: [GameQuestion] = []
        
        randomNumbers.forEach { number in
            myConnectionsRef
                .child(game.koreanString)
                .child("\(number)")
                .getData { error, dataSnapshot in
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
                    
//                    CurrentUserInfo.currentQuestions.append(data)
                    currentQuestions.append(data)
                    self.myConnectionsRef
                        .child("rooms")
                        .child(CurrentUserInfo.currentRoom!.uuidString)
                        .child("questions")
                        .child("\(currentQuestions.count - 1)")
                        .setValue([
                            "data": "\(data.data)",
                            "answer": "\(data.answer)",
                            "playerAnswer": ""
                        ])
                }
            
        }
        
        performSegue(withIdentifier: "moveToLobby", sender: nil)
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
