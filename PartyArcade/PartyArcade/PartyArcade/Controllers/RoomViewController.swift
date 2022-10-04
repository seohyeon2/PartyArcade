//
//  RoomViewController.swift
//  PartyArcade
//
//  Created by LeeChiheon on 2022/10/04.
//

import UIKit

class RoomViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func hostButtonTapped(_ sender: UIButton) {
        CurrentUserInfo.isHost = true
        
    }
    
    @IBAction func clientButtonTapped(_ sender: UIButton) {
        CurrentUserInfo.isHost = false
    }
    
}
