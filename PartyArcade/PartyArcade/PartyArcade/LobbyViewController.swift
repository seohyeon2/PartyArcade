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
    
    var playerCount: Int = 0
    var playerList: [UserInfo] = []
    var playerNameList: [String] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userlistTableView.delegate = self
        userlistTableView.dataSource = self
        
        myConnectionsRef.child("connections").observe(.value) { dataSnapshot in
            
            guard let playerList = (dataSnapshot.value as? [String: [String: Any]]) else { return }
            
            let mapped = playerList.map { asd -> UserInfo in
                guard let data = try? JSONSerialization.data(withJSONObject: asd.value),
                      let object = try? JSONDecoder().decode(UserInfo.self, from: data) else { return UserInfo(name: "", uuid: UUID(), loginTime: 0.0) }
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
