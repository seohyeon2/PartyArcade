//
//  MainViewController.swift
//  PartyArcade
//
//  Created by LeeChiheon on 2022/10/04.
//

import UIKit
import FirebaseDatabase

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
            .setValue(["game": game.rawValue])
        myConnectionsRef
            .child("rooms")
            .child(inviteCode.uuidString)
            .onDisconnectRemoveValue()
        
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
        
    }
    
}
