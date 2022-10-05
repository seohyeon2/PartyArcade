//
//  CurrentUserInfo.swift
//  PartyArcade
//
//  Created by LeeChiheon on 2022/10/04.
//

import Foundation

final class CurrentUserInfo {
    static var userInfo: UserInfo? = nil
    static var isHost: Bool? = nil
    static var currentGame: Game?
    static var currentRoom: UUID? = nil
    private init() { }
}
