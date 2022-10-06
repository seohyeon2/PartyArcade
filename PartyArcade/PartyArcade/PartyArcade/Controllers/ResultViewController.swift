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
    var rank = 1
    var index = 0
    
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
}

extension ResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        
        var isEqual = false
    
        print(index, list.count)
        if index < list.count-1 {
            isEqual = list[index].value == list[index+1].value ? true : false
        }
        
        if !isEqual {
            rank += 1
        }
        
        index += 1
        
        
        cell.textLabel?.font = .preferredFont(forTextStyle: .title3)
        cell.textLabel?.text = "\(rank)등 : \(list[indexPath.row].key)"
        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .body)
        cell.detailTextLabel?.text = "맞춘 개수 : \(list[indexPath.row].value)"
        
        return cell
    }
}
