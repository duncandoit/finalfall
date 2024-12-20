//
//  Kiri.swift
//  BoardGame
//
//  Created by Zachary Duncan on 4/14/21.
//

import Foundation

class Kiri: Piece {
    init() {
        super.init(name: HeroName.kiri.rawValue, role: .dps, health: 150, shield: 50)
        movementVectors = [Vector(directions: .all, range: 1)]
        
        spriteScale = 1.3
        
        addAbility(FusingBeam())
        addAbility(M1())
        addAbility(GravityWell())
        addAbility(Overcharge())
    }
    
    override func setup(onSquare square: SquareNode, board: BoardScene, team: Team) {
        spriteScale = 0.75
        spriteOffsetY = square.height * 0.35
        healthbarOffsetY = -(square.height * 0.25)
        
        super.setup(onSquare: square, board: board, team: team)
    }
}

fileprivate class FusingBeam: BaseAbility {
    override init() {
        super.init()
        
        name = "Fusing Beam"
        vectors = [Vector(directions: .lateral, range: 3)]
        
        let attackAmount = 70
        primaryEffects = [Damage(attackAmount)]
        description = "A ranged electron beam from her fusing tool, dealing \(attackAmount) damage"
    }
}

fileprivate class M1: BaseAbility {
    override init() {
        super.init()
        
        name = "M1"
        vectors = [Vector(directions: .all, range: 4)]
        penetrates = true
        
        primaryEffects = [AOE(Status.burn, range: 1, type: type)]
        description = "Sends out M1 who gleefully speeds over to an enemy, sets fire to their clothes then flies back. The fire spreads to nearby enemies"
        cooldown = 3
    }
}

fileprivate class GravityWell: BaseAbility {
    override init() {
        super.init()
        
        name = "Gravity Well"
        vectors = [Vector(directions: .all, range: 3)]
        
        let amount = 10
        type = .deploy
        description = "Lays down a trap. An enemy caught in its intense gravitational pull will be damaged \(amount) and rooted"
        cooldown = 5
    }
    
    override func preExecute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        let newPiece = PieceService.newHeroPiece(.kiri)
        newPiece.setup(onSquare: targetSquare, board: (source.observer as! BoardScene), team: source.team)
        
        super.preExecute(source: source, target: target, targetSquare: targetSquare, direction: direction)
    }
}

fileprivate class Overcharge: UltimateAbility {
    override init() {
        super.init()
        
        name = "Overcharge"
        let range = 5
        vectors = [Vector(directions: .lateral, range: range)]
        
        let amount = 70
        primaryEffects = [Multitarget(Damage(amount), range: range, type: type), Multitarget(Status.burn, range: range, type: type)]
        description = "Overcharges her fusing device to emit a white hot long range beam that hits every enemy for \(range) spaces and sets their little pants on fire"
    }
}
