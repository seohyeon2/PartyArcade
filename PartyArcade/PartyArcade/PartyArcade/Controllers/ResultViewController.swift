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
    let list = [Dictionary<String, Int>.Element]()
    
    let myConnectionsRef = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()

    @IBOutlet weak var rankingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                
                let usersResult = data.flatMap {
                    $0.value
                }.sorted {
                    $0.value > $1.value
                }
                self.rankingTableView.reloadData()
            }
    }
}

extension ResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
        return cell
    }
}
