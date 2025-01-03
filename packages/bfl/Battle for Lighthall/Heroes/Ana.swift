//
//  Ana.swift
//  BoardGame
//
//  Created by Zachary Duncan on 4/14/21.
//

import Foundation

class Ana: Piece {
    init() {
        super.init(name: HeroName.ana.rawValue, role: .healer, health: 50, shield: 100, ultCharge: 375)
        movementVectors = [Vector(directions: .diagonal, range: 2), Vector(directions: .lateral, range: 1)]
        
        spriteScale = 1.2
        
        addAbility(ChemicalDart())
        addAbility(SleepDart())
        addAbility(CursedTouch())
        addAbility(FullHeal())
    }
    
    override func setup(onSquare square: SquareNode, board: BoardScene, team: Team) {
        spriteOffsetY = square.height * 0.25
        
        super.setup(onSquare: square, board: board, team: team)
    }
}

fileprivate class ChemicalDart: BaseAbility {
    override init() {
        super.init()
        
        name = "Chemical Dart"
        emblem = #imageLiteral(resourceName: "Ana_Full Heal_0")
        type = [.damage, .heal]
        penetrates = true
        vectors = [Vector(directions: .diagonal, range: 3)]
        
        let attackAmount: Float = 40
        primaryEffects = [HealDamageCombo(attackAmount)]
        description = "A diagonal long ranged shot that damages an enemy \(attackAmount) or heals an ally \(attackAmount * 2)"
    }
}

fileprivate class SleepDart: BaseAbility {
    override init() {
        super.init()
        
        name = "Sleep Dart"
        emblem = #imageLiteral(resourceName: "Ana_Full Heal_0")
        vectors = [Vector(directions: .diagonal, range: 2)]
        secondaryEffects = [Status.sleep]
        description = "A diagonal medium ranged dart that causes sleep"
        cooldown = 3
    }
}

fileprivate class CursedTouch: BaseAbility {
    override init() {
        super.init()
        
        name = "Cursed Touch"
        emblem = #imageLiteral(resourceName: "Ana_Full Heal_0")
        vectors = [Vector(directions: .diagonal, range: 1)]
        
        primaryEffects = [AOE(Status.cursed, range: 1, type: type)]
        description = "Touch a diagonally adjacent enemy to spread a curse to them and their adjacent allies"
        cooldown = 5
    }
}

fileprivate class FullHeal: UltimateAbility {
    override init() {
        super.init()
        
        name = "Full Heal"
        emblem = #imageLiteral(resourceName: "Ana_Full Heal_0")
        type = .heal
        vectors = [Vector(directions: .all, range: 3), Vector(directions: .up, range: 0)]
        
        let duration = 2
        primaryEffects = [Cure()]
        secondaryEffects = [Heal(1000, duration: duration)]
        description = "Cures and then fully heals a friendly hero for \(duration) turns"
    }
}
