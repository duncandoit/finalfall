//
//  Mercy.swift
//  BoardGame
//
//  Created by Zachary Duncan on 4/14/21.
//

import Foundation

class Mercy: Piece {
    init() {
        super.init(name: HeroName.mercy.rawValue, role: .healer, health: 25, shield: 150, ultCharge: 500)
        movementVectors = [Vector(directions: .all, range: 2)]
        
        spriteScale = 1.3
        
        addAbility(HealingBeam())
        addAbility(Cleanse())
        addAbility(Radiance())
    }
    
    override func setup(onSquare square: SquareNode, board: BoardScene, team: Team) {
        spriteOffsetY = square.height * 0.45
        healthbarOffsetY = square.height * 0.15
        
        super.setup(onSquare: square, board: board, team: team)
    }
}

fileprivate class HealingBeam: BaseAbility {
    override init() {
        super.init()
        
        name = "Healing Beam"
        emblem = #imageLiteral(resourceName: "Mercy_Death_0")
        type = .heal
        vectors = [Vector(directions: .all, range: 1), Vector(directions: .up, range: 0)]
        
        let amount: Float = 40
        let duration = 3
        secondaryEffects = [Heal(amount, duration: duration)]
        description = "A beam of energy that heals \(amount) per turn for \(duration) turns"
    }
}

fileprivate class Cleanse: BaseAbility {
    override init() {
        super.init()
        
        name = "Cleanse"
        emblem = #imageLiteral(resourceName: "Mercy_Death_0")
        type = .heal
        vectors = [Vector(directions: .all, range: 1), Vector(directions: .up, range: 0)]
        primaryEffects = [Cure()]
        description = "Removes any status impairment from a friendly hero"
        cooldown = 5
    }
}

fileprivate class Radiance: UltimateAbility {
    override init() {
        super.init()
        
        name = "Radiance"
        emblem = #imageLiteral(resourceName: "Mercy_Death_0")
        type = .heal
        vectors = [Vector(directions: .up, range: 0)]
        
        let amount: Float = 100
        let range = 1
        let duration = 4
        secondaryEffects = [Heal(amount, duration: duration, aoeRange: range)]
        description = "Radiates pulses of \(amount) healing passively within \(range) space in every direction for \(duration) turns"
        cooldown = duration
    }
}
