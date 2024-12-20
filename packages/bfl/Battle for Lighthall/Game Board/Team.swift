//
//  Team.swift
//  BoardGame
//
//  Created by Zachary Duncan on 2/17/21.
//

import UIKit

class Team {
    let name: String
    let color: UIColor
    var theirTurn: Bool
    var heroes: [Piece] = []
    var deployables: [Piece] = []
    var usedAbility: Bool = false
    
    init(name: String, color: UIColor, theirTurn: Bool) {
        self.name = name
        self.color = color
        self.theirTurn = theirTurn
    }
    
    func add(piece: Piece) {
        heroes.append(piece)
    }
    
    func remove(piece: Piece) {
        heroes.removeAll { $0 === piece }
    }
    
    func hasTeamMember(_ piece: Piece) -> Bool {
        return heroes.contains(piece)
    }
    
    func startTurn() {
        usedAbility = false
        
        for hero in heroes {
            hero.affectedByDebuffs()
            hero.resolveUnstoppable()
        }
    }
    
    func endTurn() {
        for hero in heroes {
            hero.deselect()
            hero.commitToOccupiedSquare()
            hero.affectedByBuffs()
            hero.chargeUltTurnEnd()
            
            for var ability in hero.abilities where ability.remainingCooldown > 0 {
                ability.remainingCooldown -= 1
            }
        }
    }
}

extension Team: Equatable {
    static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs === rhs
    }
}

enum TeamRole {
    case tank
    case dps
    case healer
    case deployable
}
