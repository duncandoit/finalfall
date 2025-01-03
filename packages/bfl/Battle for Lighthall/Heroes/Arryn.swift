//
//  Arryn.swift
//  BoardGame
//
//  Created by Zachary Duncan on 4/14/21.
//

import SpriteKit

class Arryn: Piece {
    init() {
        super.init(name: HeroName.arryn.rawValue, role: .tank, health: 250, shield: 50)
        movementVectors = [Vector(directions: .lateral, range: 2), Vector(directions: .diagonal, range: 1)]
        
        spriteScale = 2
        
        addAbility(Bash())
        addAbility(FierySlash())
        addAbility(Charge())
        addAbility(SonicBoom())
    }
    
    override func setup(onSquare square: SquareNode, board: BoardScene, team: Team) {
        spriteOffsetY = square.height * 0.55
        
        super.setup(onSquare: square, board: board, team: team)
    }
}

fileprivate class Bash: BaseAbility {
    override init() {
        super.init()
        
        name = "Bash"
        emblem = #imageLiteral(resourceName: "Arryn_Bash_2")
        vectors = [Vector(directions: .all, range: 1)]
        
        let attackAmount: Float = 50
        primaryEffects = [ForceMove(distance: 1, isAOE: false), Damage(attackAmount)]
        description = "Bash your enemy violently with your shield, dealing \(attackAmount) damage and knocking them back"
    }
    
    override func preExecute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        source.playAbilityAnimation(self, direction: direction)
        execute(source: source, target: target, targetSquare: targetSquare, direction: direction)
        
    }
}

fileprivate class FierySlash: BaseAbility {
    override init() {
        super.init()
        
        name = "Fiery Slash"
        emblem = #imageLiteral(resourceName: "Arryn_Sonic Boom_8")
        vectors = [Vector(directions: .lateral, range: 2)]
        
        let attackAmount: Float = 70
        primaryEffects = [Damage(attackAmount)]
        secondaryEffects = [Status.burn]
        description = "Sends a plume of flame wheeling out in front of him with a slash of his fiery sword dealing \(attackAmount) damage and causing burn"
        cooldown = 5
    }
}

fileprivate class Charge: BaseAbility {
    let damage: Float = 50
    
    override init() {
        super.init()
        
        name = "Charge"
        emblem = #imageLiteral(resourceName: "Arryn_Charge_3")
        type = [.damage, .movement]
        let moveDistance = 3
        vectors = [Vector(directions: .lateral, range: moveDistance)]
        
        let stackSize = 2
        primaryEffects = [ForceMove(distance: moveDistance, stackSize: stackSize, selfTargetAbilityName: name)]
        description = "Charge \(moveDistance) spaces laterally at an enemy pushing them back and dealing \(damage) damage if pinned"
        cooldown = 5
    }
    
    override func preExecute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        // We override so that the ability animation doesn't play at the start
        let action = source.abilityTextureAction(name, direction: direction)
        execute(source: source, target: target, targetSquare: targetSquare, direction: direction, delay: action.duration)
    }
    
    override func postExecute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        guard let target = target else { fatalError() }
        var damaged = false
        
        if source.distanceTo(target: target, direction: direction) == 0 {
            if let squareBehindTarget = target.occupiedSquare.direction(by: 1, direction: direction) {
                if squareBehindTarget.hero != nil {
                    damaged = true
                } else {
                    // If there is an empty square behind the target, it will be booped to it
                    let fall = target.fallTextureAction(direction: direction)
                    let snap = target.snapAction(to: squareBehindTarget, direction: direction, duration: fall.duration, commit: true)
                    target.animate([snap, fall])
                }
            } else {
                damaged = true
            }
        }
        
        source.playAbilityAnimation(Bash(), direction: direction)
        
        if damaged {
            target.damage(by: damage, direction: direction, source: source)
        }
        
        super.postExecute(source: source, target: target, targetSquare: targetSquare, direction: direction)
    }
}

fileprivate class SonicBoom: UltimateAbility {
    override init() {
        super.init()
        
        name = "Sonic Boom"
        emblem = #imageLiteral(resourceName: "Arryn_Fall_0")
        vectors = [Vector(directions: .up, range: 0)]
        
        let attackAmount: Float = 20
        primaryEffects = [AOE(Status.stun, range: 2, type: type),
                          Damage(attackAmount, aoeRange: 2, penetrates: true),
                          ForceMove(distance: 1, isAOE: true, stackSize: 2)]
        
        description = "Activates a device that emits a gigantic sonic boom which knocks back and stuns surrounding enemies, dealing \(attackAmount) damage"
    }
    
    override func preExecute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        let textureAction: SKAction = source.abilityTextureAction(name, direction: direction)
        let moveUp = SKAction.move(by: CGVector(dx: 0, dy: source.occupiedSquare.height), duration: textureAction.duration / 3)
        moveUp.timingMode = .easeOut
        let jumpLand = SKAction.sequence([moveUp, moveUp.reversed()])
        let healthbar = source.alignHealthbarAction(duration: textureAction.duration)
        let group = SKAction.group([jumpLand, textureAction, healthbar])
        
        source.sprite.run(group) {
            self.execute(source: source, target: target, targetSquare: targetSquare, direction: direction)
        }
    }
}
