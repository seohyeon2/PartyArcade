//
//  LobbyViewController.swift
//  PartyAracade
//
//  Created by LeeChiheon on 2022/10/03.
//

import UIKit
import FirebaseDatabase
import FirebaseDatabaseSwift
import FirebaseSharedSwift

class LobbyViewController: UIViewController {
    
    // MARK: - Properties
    
    let myConnectionsRef = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    
    
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var userlistTableView: UITableView!
    @IBOutlet weak var inviteCodeTextView: UITextView!
    @IBOutlet weak var startGameButton: UIButton!
    
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
        
        gameNameLabel.text = "현재 게임 : \(currentGame.string)"
        inviteCodeTextView.isEditable = false
        inviteCodeTextView.textContainer.maximumNumberOfLines = 1
        inviteCodeTextView.text = "\(inviteCode)"
        
        myConnectionsRef
            .child("rooms")
            .child(inviteCode)
            .observe(.value) { dataSnapshot in
                
                print("### 리스트 업데이트 ###")
                
                guard dataSnapshot.exists() else {
                    self.showAlert(message: "방이 사라졌어요") {
                        self.view.window?.rootViewController?.dismiss(animated: true)
                    }
                    return
                }
                                
                guard let room = try? FirebaseDataDecoder().decode(Room.self, from: dataSnapshot.value) else { return }
                if room.isPlaying {
                    self.performSegue(withIdentifier: "moveToGamePlaying", sender: nil)
                }
                
                let mapped = room.userList.map {
                    $0.value
                }
                let sorted = mapped.sorted { $0.loginTime < $1.loginTime }
                
                self.playerCount = sorted.count
                self.playerList = sorted
                let me = self.playerList.filter { $0.uuid == CurrentUserInfo.userInfo?.uuid }
                
                guard me.isEmpty == false else {
                    self.view.window?.rootViewController?.dismiss(animated: true)
                    return
                }
                
                // 내가 방장인지 확인
                CurrentUserInfo.isHost = me.first?.isHost
                if CurrentUserInfo.isHost == true {
                    self.myConnectionsRef
                        .child("rooms")
                        .child(CurrentUserInfo.currentRoom!.uuidString)
                        .onDisconnectRemoveValue()
                    self.startGameButton.isEnabled = true
                } else {
                    self.myConnectionsRef
                        .child("rooms")
                        .child(CurrentUserInfo.currentRoom!.uuidString)
                        .cancelDisconnectOperations()
                    self.startGameButton.isEnabled = false
                }
                
                self.playerNameList = sorted.map { $0.name }
                
                // 테이블뷰 업데이트
                let range = NSMakeRange(0, self.userlistTableView.numberOfSections)
                let sections = NSIndexSet(indexesIn: range)
                self.userlistTableView.reloadSections(sections as IndexSet, with: .automatic)
            }
    }
    
    // MARK: - Button Actions
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        guard let isHost = CurrentUserInfo.isHost,
              let currentRoom = CurrentUserInfo.currentRoom,
              let currentUserUUID = CurrentUserInfo.userInfo?.uuid else { return }
        if isHost {
            let alertController = UIAlertController(title: "님은 방장이에요", message: "방장이 나가면 방이 사라질 수 있어요.\n정말 나가시겠어요? 🤔", preferredStyle: .alert)
            let yes = UIAlertAction(title: "네", style: .destructive) { _ in
                self.myConnectionsRef
                    .child("rooms")
                    .child(currentRoom.uuidString)
                    .removeValue() { _, _ in
                        self.view.window?.rootViewController?.dismiss(animated: true)
                    }
            }
            let no = UIAlertAction(title: "아니요", style: .cancel)
            alertController.addAction(yes)
            alertController.addAction(no)
            
            present(alertController, animated: true)
            
        } else {
            myConnectionsRef
                .child("rooms")
                .child(currentRoom.uuidString)
                .child("userList")
                .child(currentUserUUID.uuidString)
                .removeValue() { _, _ in
                    self.view.window?.rootViewController?.dismiss(animated: true)
                }
        }
        
    }
    
    
    @IBAction func gameStartButtonTapped(_ sender: UIButton) {
        myConnectionsRef
            .child("rooms")
            .child(CurrentUserInfo.currentRoom!.uuidString)
            .child("isPlaying")
            .setValue(true)
    }
    

    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard let inviteCode = inviteCodeTextView.text else { return }
        let activityVC = UIActivityViewController(activityItems: [inviteCode], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    // MARK: - Methods
    
    private func showAlert(message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.dismiss(animated: true) {
                completion?()
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension LobbyViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard CurrentUserInfo.isHost! else { return nil }
        
        if playerList[indexPath.row].isHost == false {
            
            // 방장 임명 기능
            let changeHost = UIContextualAction(style: .normal, title: "방장임명") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
                
                var oldHost = CurrentUserInfo.userInfo
                oldHost?.isHost = false
                
                var selectedPlayer = self.playerList[indexPath.row]
                selectedPlayer.isHost = true
                
                guard let hostEncodedData = try? JSONEncoder().encode(oldHost),
                      let hostJsonData = try? JSONSerialization.jsonObject(with: hostEncodedData) else { return }
                
                
                guard let clientEncodedData = try? JSONEncoder().encode(selectedPlayer),
                      let clientJsonData = try? JSONSerialization.jsonObject(with: clientEncodedData) else { return }
                
                self.myConnectionsRef
                    .child("rooms")
                    .child(CurrentUserInfo.currentRoom!.uuidString)
                    .child("userList")
                    .updateChildValues([
                        self.playerList[indexPath.row].uuid.uuidString : clientJsonData,
                        oldHost!.uuid.uuidString: hostJsonData
                    ])
                
                success(true)
            }
            changeHost.backgroundColor = .systemTeal
            
            // 강퇴 기능
            let kick = UIContextualAction(style: .destructive, title: "강퇴") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
                
                self.myConnectionsRef
                    .child("rooms")
                    .child(CurrentUserInfo.currentRoom!.uuidString)
                    .child("userList")
                    .child(self.playerList[indexPath.row].uuid.uuidString)
                    .removeValue()

                
                success(true)
            }
            kick.backgroundColor = .systemPink
            
            let swipeAction = UISwipeActionsConfiguration(actions:[kick, changeHost])
            swipeAction.performsFirstActionWithFullSwipe = false
            
            return swipeAction
        }
        
        return nil
    }
    
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
