//
//  River.swift
//  BoardGame
//
//  Created by Zachary Duncan on 4/14/21.
//

import Foundation

class River: Piece {
    init() {
        super.init(name: HeroName.river.rawValue, role: .dps, health: 150, shield: 25)
        movementVectors = [Vector(directions: .lateral, range: 3), Vector(directions: .diagonal, range: 1)]
        
        spriteScale = 0.9
        
        addAbility(PoisonJab())
        addAbility(DeathGrip())
        addAbility(CellOverload())
    }
    
    override func setup(onSquare square: SquareNode, board: BoardScene, team: Team) {
        spriteOffsetY = square.height * 0.4
        healthbarOffsetY = -(square.height * 0.25)
        
        super.setup(onSquare: square, board: board, team: team)
    }
}

fileprivate class PoisonJab: BaseAbility {
    override init() {
        super.init()
        
        name = "Poison Jab"
        emblem = #imageLiteral(resourceName: "River_Idle_0")
        vectors = [Vector(directions: .lateral, range: 2)]
        
        let attackAmount: Float = 60
        primaryEffects = [Damage(attackAmount)]
        secondaryEffects = [Status.poison]
        description = "Medium range thrust of his ornate polearm with a poison coated tip. Causes \(attackAmount) damage and the target is poisoned"
    }
}

fileprivate class DeathGrip: BaseAbility {
    override init() {
        super.init()
        
        name = "Death Grip"
        emblem = #imageLiteral(resourceName: "River_Idle_0")
        vectors = [Vector(directions: .all, range: 1)]
        
        let attackAmount: Float = 90
        primaryEffects = [Damage(attackAmount)]
        secondaryEffects = [Status.immobilize]
        description = "Grapples the enemy and stabs them through a gap in their armor using a small dagger coated with a toxin, known only to his tribe, which causes its victim’s legs to seize up. Deals \(attackAmount) damage and causes root"
        cooldown = 4
    }
}

fileprivate class CellOverload: UltimateAbility {
    override init() {
        super.init()
        
        name = "Cell Overload"
        emblem = #imageLiteral(resourceName: "River_Idle_0")
        vectors = [Vector(directions: .up, range: 0)]
        
        let amount: Float = 30
        let range = 1
        let duration = 3
        primaryEffects = [Damage(amount, aoeRange: range)]
        secondaryEffects = [Secondary(Damage(amount, aoeRange: range), duration: duration)]
        description = "An overloaded energy cell rigged to continuously detonate, emits pulses of energy dealing \(amount) damage to all surrounding pieces for \(duration) turns"
        cooldown = duration
    }
}
