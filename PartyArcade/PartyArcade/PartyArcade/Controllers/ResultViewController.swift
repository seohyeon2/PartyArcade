//
//  ResultViewController.swift
//  PartyArcade
//
//  Created by seohyeon park on 2022/10/06.
//

import UIKit
import FirebaseDatabase
import FirebaseSharedSwift

struct UserResult {
    let player: String
    let data: Int
}

class ResultViewController: UIViewController {
    var list = [Dictionary<String, Int>.Element]()
    
    let myConnectionsRef = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()

    @IBOutlet weak var rankingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rankingTableView.delegate = self
        rankingTableView.dataSource = self
        
        myConnectionsRef
            .child("rooms")
            .child(CurrentUserInfo.currentRoom!.uuidString)
            .child("answerList")
            .observe(.value) { dataSnapshot in
                print(dataSnapshot.value)

                guard let data = dataSnapshot.value as? [String: [String: Int]] else {
                    print("🍕")
                    return
                }

                self.list = data.flatMap {
                    $0.value
                }.sorted {
                    $0.value > $1.value
                }
                
                self.rankingTableView.reloadData()
            }
    }
    
    @IBAction func exitButtonTapped(_ sender: UIButton) {
        guard let isHost = CurrentUserInfo.isHost,
              let currentRoom = CurrentUserInfo.currentRoom,
              let currentUserUUID = CurrentUserInfo.userInfo?.uuid else { return }
        if isHost {
            myConnectionsRef
                .child("rooms")
                .child(currentRoom.uuidString)
                .removeValue()
        } else {
            myConnectionsRef
                .child("rooms")
                .child(currentRoom.uuidString)
                .child("userList")
                .child(currentUserUUID.uuidString)
                .removeValue()
        }
        
        self.view.window?.rootViewController?.dismiss(animated: true)
    }
}

extension ResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row). \(list[indexPath.row].key)"
        cell.detailTextLabel?.text = list[indexPath.row].value.description
        
        return cell
    }
}
