//
//  IKYWordData.swift
//  I know you
//
//  Created by doxie on 5/29/18.
//  Copyright © 2018 Xie. All rights reserved.
//

import Foundation
import UIKit

class IKYWordData {
    var teamColorEnum: TeamColor
    var vocabulary: String
    let redTeamColor = UIColor.red.withAlphaComponent(0.5)
    let blueTeamColor = UIColor.blue.withAlphaComponent(0.5)
    let yellowTeamColor = UIColor.yellow.withAlphaComponent(0.5)
    let boomColor = UIColor.brown

    init(teamColor: TeamColor, vocabulary: String) {
        self.teamColorEnum = teamColor
        self.vocabulary = vocabulary
    }

    init(string: String) {
        let strs: [String] = string.components(separatedBy: CharacterSet.init(charactersIn: ":"))
        if strs.count == 2 {
            self.teamColorEnum = TeamColor(rawValue: Int(strs[0])!)!
            self.vocabulary = strs[1]
        } else {
            self.teamColorEnum = .boomColor
            self.vocabulary = "转换错误"
        }
    }

    func teamColor() -> UIColor {
        switch self.teamColorEnum {
        case .boomColor:
            return boomColor
        case .redTeamColor:
            return redTeamColor
        case .blueTeamColor:
            return blueTeamColor
        case .yellowTeamColor:
            return yellowTeamColor
        }
    }

    func encode() -> String {
        let str = NSMutableString.init()
        str.append(String(self.teamColorEnum.rawValue))
        str.append(":")
        str.append(self.vocabulary)

        return str as String
    }

}


