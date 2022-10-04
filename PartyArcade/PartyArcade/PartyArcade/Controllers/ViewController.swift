//
//  ViewController.swift
//  PartyArcade
//
//  Created by hyeon, finnn on 2022/10/03.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    let database = Database.database(url: "https://partyarcade-c914b-default-rtdb.asia-southeast1.firebasedatabase.app").reference()
    let connectedRef = Database.database().reference(withPath: ".info/connected")
    let myConnectionsRef = Database.database().reference(withPath: "users/morgan/connections")
    
    @IBOutlet weak var mainLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectedRef.observe(.value) { snapshot in
            print(snapshot.value)
            if snapshot.value as? Int == 0 {
                print("Connected")
            } else {
                print("Not connected")
            }
        }
        
        database.observe(.value) { dataSnapshot in
            print(dataSnapshot.value)
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.locale = .current
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        let formattedDate = dateFormatter.string(from: Date())
        
        database.child(UUID().uuidString) .setValue(formattedDate)
    }
    
    @IBAction func getButtonTapped(_ sender: UIButton) {
        database.getData { error, dataSnapshot in
            print(error)
        }
    }

}
