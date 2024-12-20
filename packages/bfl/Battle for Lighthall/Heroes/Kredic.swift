//
//  Kredic.swift
//  BoardGame
//
//  Created by Zachary Duncan on 4/14/21.
//

import Foundation

class Kredic: Piece {
    init() {
        super.init(name: HeroName.kredic.rawValue, role: .dps, health: 75, shield: 75)
        movementVectors = [Vector(directions: .all, range: 1)]
        
        spriteScale = 2
        
        addAbility(Fireball())
        addAbility(Fear())
        addAbility(Blizzard())
    }
    
    override func setup(onSquare square: SquareNode, board: BoardScene, team: Team) {
        spriteOffsetY = square.height * 0.45
        healthbarOffsetY = square.height * 0.3
        
        super.setup(onSquare: square, board: board, team: team)
    }
}

fileprivate class Fireball: BaseAbility {
    override init() {
        super.init()
        
        name = "Fireball"
        emblem = #imageLiteral(resourceName: "Kredic_Fireball_6")
        vectors = [Vector(directions: .all, range: 3)]
        
        let amount = 40
        primaryEffects = [Damage(amount), AOE(Status.burn, range: 1, type: type)]
        description = "Long range fireball dealing \(amount) and buring all adjacent pieces"
    }
}

fileprivate class Fear: BaseAbility {
    override init() {
        super.init()
        
        name = "Fear"
        emblem = #imageLiteral(resourceName: "Kredic_Fear_6")
        vectors = [Vector(directions: .lateral, range: 1)]
        
        let amount = 25
        primaryEffects = [Damage(amount, ignoreShields: true)]
        secondaryEffects = [Status.disable]
        description = "Peer deep into your enemy's eyes inflicting \(amount) magic damage and causing disable"
        cooldown = 3
    }
}

fileprivate class Blizzard: UltimateAbility {
    override init() {
        super.init()
        
        name = "Blizzard"
        emblem = #imageLiteral(resourceName: "Kredic_Blizzard_5")
        vectors = [Vector(directions: .all, range: 2)]
        
        let duration = 3
        primaryEffects = [AOE(Status.freeze, range: 2, type: type)]
        description = "Feezes all enemies adjacent to your target"
        cooldown = duration
    }
}
