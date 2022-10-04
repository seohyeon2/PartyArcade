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
        inviteCodeTextView.textContainer.maximumNumberOfLines = 1
        inviteCodeTextView.text = "\(inviteCode)"
        
        myConnectionsRef
            .child("rooms")
            .child(inviteCode)
            .observe(.value) { dataSnapshot in
                
                guard dataSnapshot.exists() else {
                    print("호스트가 나가서 방이 사라짐.")
                    self.view.window?.rootViewController?.dismiss(animated: true)
                    return
                }
                
                print(dataSnapshot)
                guard let asd = try? JSONSerialization.data(withJSONObject: dataSnapshot.value) else {
                    print("error")
                    return
                }
                let zxc = try? JSONDecoder().decode(Room.self, from: asd)
                
                let mapped = zxc?.userList.map {
                    $0.value
                }
                let optionalSorted = mapped?.sorted { $0.loginTime < $1.loginTime }
                
                guard let sorted = optionalSorted else { return }
                
                self.playerList = sorted
                self.playerNameList = sorted.map { $0.name }
                
                self.playerCount = sorted.count
                let range = NSMakeRange(0, self.userlistTableView.numberOfSections)
                let sections = NSIndexSet(indexesIn: range)
                self.userlistTableView.reloadSections(sections as IndexSet, with: .automatic)
            } withCancel: { error in
                print(error)
            }
    }
    
    // MARK: - Button Actions
    
    @IBAction func changeNicknameButtonTapped(_ sender: UIButton) {
        if CurrentUserInfo.isHost! {
            myConnectionsRef
                .child("rooms")
                .child(CurrentUserInfo.currentRoom!.uuidString)
                .removeValue()
        } else {
            myConnectionsRef
                .child("rooms")
                .child(CurrentUserInfo.currentRoom!.uuidString)
                .child("userList")
                .child(CurrentUserInfo.userInfo!.uuid.uuidString)
                .removeValue()
        }
        
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
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard let inviteCode = inviteCodeTextView.text else { return }
        let activityVC = UIActivityViewController(activityItems: [inviteCode], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension LobbyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension LobbyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userlistTableView.dequeueReusableCell(withIdentifier: "playerInfoCell", for: indexPath)
        
        if playerList[indexPath.row].isHost {
            cell.imageView?.image = UIImage(named: "host")
        } else {
            cell.imageView?.image = UIImage(named: "client")
        }
        
        cell.textLabel?.text = playerList[indexPath.row].name
        
        return cell
    }
}
