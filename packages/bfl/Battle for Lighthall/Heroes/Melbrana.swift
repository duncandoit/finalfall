//
//  Melbrana.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 5/10/21.
//

import Foundation

class Melbrana: Piece {
    init() {
        super.init(name: HeroName.melbrana.rawValue, role: .tank, health: 250, shield: 50)
        movementVectors = [Vector(directions: .lateral, range: 2), Vector(directions: .diagonal, range: 1)]
        
        spriteScale = 2
        
        addAbility(Sunder())
        addAbility(Slam())
        addAbility(BattleCry())
        addAbility(Rampage())
    }
    
    override func setup(onSquare square: SquareNode, board: BoardScene, team: Team) {
        spriteScale = 1
        spriteOffsetY = square.height * 0.4
        healthbarOffsetY = -(square.height * 0.25)
        
        super.setup(onSquare: square, board: board, team: team)
    }
}

fileprivate class Sunder: BaseAbility {
    override init() {
        super.init()
        
        name = "Sunder"
        emblem = #imageLiteral(resourceName: "Melbrana Portrait")
        vectors = [Vector(directions: .all, range: 1)]
        
        let attackAmount = 50
        primaryEffects = [Damage(Float(attackAmount))]
        description = "Brutal hammer swing, dealing \(attackAmount) damage"
    }
}

fileprivate class Slam: BaseAbility {
    override init() {
        super.init()
        
        name = "Slam"
        emblem = #imageLiteral(resourceName: "Melbrana Portrait")
        vectors = [Vector(directions: .lateral, range: 1)]
        
        let attackAmount = 70
        primaryEffects = [Damage(Float(attackAmount))]
        secondaryEffects = [Status.stun]
        description = "Picks up an enemy by the throat and throws them to the ground causing \(attackAmount) damage and stun"
        cooldown = 4
    }
}

fileprivate class BattleCry: BaseAbility {
    override init() {
        super.init()
        
        name = "Battle Cry"
        emblem = #imageLiteral(resourceName: "Melbrana Portrait")
        type = .heal
        vectors = [Vector(directions: .up, range: 0), Vector(directions: .all, range: 3)]
        penetrates = true
        
        let duration = 3
        secondaryEffects = [Status(.unstoppable, duration: duration), Status(.amplified, duration: duration)]
        description = "Removes and prohibits movement impairing effects, grants attack amplification to an ally target for \(duration) turns"
        cooldown = 7
    }
}

fileprivate class Rampage: UltimateAbility {
    override init() {
        super.init()
        
        name = "Rampage"
        emblem = #imageLiteral(resourceName: "Melbrana Portrait")
        type = .damage
        vectors = [Vector(directions: .up, range: 0)]
        
        let duration = 4
        secondaryEffects = [Status(.amplified, duration: duration), Status(.speed, duration: duration), Status(.immortal, duration: duration)]
        description = "Gives her a speed boost, damage amplification and activates a high density energy field around her that prevents her from taking mortal damage for \(duration) turns"
        cooldown = duration
    }
}
