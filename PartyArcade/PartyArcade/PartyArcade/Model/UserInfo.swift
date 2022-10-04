//
//  UserInfo.swift
//  PartyArcade
//
//  Created by LeeChiheon on 2022/10/04.
//

import Foundation

struct UserInfo: Codable, Hashable {
    let name: String
    let uuid: UUID
    let loginTime: Double
    let isHost: Bool
}
