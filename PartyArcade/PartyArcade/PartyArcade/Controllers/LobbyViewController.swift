//
//  LobbyViewController.swift
//  PartyAracade
//
//  Created by LeeChiheon on 2022/10/03.
//

import UIKit
import FirebaseDatabase
import FirebaseDatabaseSwift

class LobbyViewController: UIViewController {
    
    // MARK: - Properties
    
    let myConnectionsRef = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    
    @IBOutlet weak var userlistTableView: UITableView!
    @IBOutlet weak var inviteCodeTextView: UITextView!
    
    var playerCount: Int = 0
    var playerList: [UserInfo] = []
    var playerNameList: [String] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userlistTableView.delegate = self
        userlistTableView.dataSource = self
        
        guard let currentGame = CurrentUserInfo.currentGame,
              let inviteCode = CurrentUserInfo.currentRoom?.uuidString else { return }
        
        inviteCodeTextView.isEditable = false
        inviteCodeTextView.textContainer.maximumNumberOfLines = 2
        inviteCodeTextView.text = "초대코드 :\n\(inviteCode)"
        
        myConnectionsRef
            .child("rooms")
            .child(inviteCode)
            .observe(.value) { dataSnapshot in
            
            print(dataSnapshot)
            guard let playerList = (dataSnapshot.value as? [String: [String: [String: Any]]]) else { return }
            
                guard let aaa = playerList.map({ bbb -> [[String: Any]] in
                    bbb.value.map({ ccc -> [String: Any] in
                        ccc.value
                    })
                }).first else { return }
                
                let mapped = aaa.map { bbb -> UserInfo in
                    guard let data = try? JSONSerialization.data(withJSONObject: bbb),
                          let object = try? JSONDecoder().decode(UserInfo.self, from: data) else {
                        return UserInfo(
                            name: "",
                            uuid: UUID(),
                            loginTime: 0.0,
                            isHost: false
                        ) }
                        
                    return object
                }
                
                
            
            let sorted = mapped.sorted { $0.loginTime > $1.loginTime }
            
            self.playerList = sorted
            self.playerNameList = sorted.map { $0.name }

            self.playerCount = sorted.count
            self.userlistTableView.reloadData()
            
        }
    }
    
    @IBAction func changeNicknameButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func gameStartButtonTapped(_ sender: UIButton) {
        guard let currentGame = CurrentUserInfo.currentGame,
              let inviteCode = CurrentUserInfo.currentRoom?.uuidString else { return }
        myConnectionsRef
            .child(currentGame.string)
            .child(inviteCode)
            .getData { error, dataSnapshot in
            print(dataSnapshot)
        }
    }
}

extension LobbyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LobbyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userlistTableView.dequeueReusableCell(withIdentifier: "playerInfoCell", for: indexPath)
        
        cell.imageView?.image = UIImage(named: "Yagom")
        cell.textLabel?.text = playerList[indexPath.row].name
        
        return cell
    }
}
