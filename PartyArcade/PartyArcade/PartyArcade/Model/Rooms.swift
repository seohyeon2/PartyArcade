//
//  Rooms.swift
//  PartyArcade
//
//  Created by LeeChiheon on 2022/10/04.
//

import Foundation

struct Room: Codable {
    let game: Game
    let isPlaying: Bool
    let userList: [String: UserInfo]
}
