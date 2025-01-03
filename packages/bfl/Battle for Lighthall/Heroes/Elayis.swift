//
//  Elayis.swift
//  BoardGame
//
//  Created by Zachary Duncan on 4/14/21.
//

import SpriteKit

class Elayis: Piece {
    init() {
        super.init(name: HeroName.elayis.rawValue, role: .tank, health: 200, shield: 50)
        movementVectors = [Vector(directions: .diagonal, range: 3), Vector(directions: .lateral, range: 2)]
        
        spriteScale = 1.5
        
        addAbility(MachineGuns())
        addAbility(Missiles())
        addAbility(Bomb())
    }
    
    override func setup(onSquare square: SquareNode, board: BoardScene, team: Team) {
        spriteOffsetY = square.height * 0.45
//        healthbarOffsetY = -(square.height * 0.1)
        
        super.setup(onSquare: square, board: board, team: team)
        
        let bombTexture = SKTexture(imageNamed: "bomb_0")
        bombTexture.preload {
            let bombNode = SKSpriteNode(texture: bombTexture)
            bombNode.position = BoardScene.offscreen
            let size = square.width * 0.95
            bombNode.size = CGSize(width: size, height: size)
            board.addChild(bombNode)
            let bombAbility = self.abilities.first { $0 is Bomb } as? Bomb
            bombAbility!.bombNode = bombNode
        }
    }
}

fileprivate class MachineGuns: BaseAbility {
    override init() {
        super.init()
        
        name = "Machine Guns"
        emblem = #imageLiteral(resourceName: "Elayis_Machine Guns_0")
        vectors = [Vector(directions: .all, range: 1)]
        
        let attackAmount: Float = 40
        primaryEffects = [Damage(attackAmount)]
        description = "A stream of bullets causing \(attackAmount) damage"
    }
}

fileprivate class Missiles: BaseAbility {
    override init() {
        super.init()
        
        name = "Missiles"
        emblem = #imageLiteral(resourceName: "Elayis_Machine Guns_0")
        vectors = [Vector(directions: .lateral, range: 1)]
        
        let attackAmount: Float = 80
        primaryEffects = [Damage(attackAmount)]
        description = "A lateral torrent of missiles dealing \(attackAmount) damage"
        cooldown = 3
    }
}

fileprivate class Bomb: UltimateAbility {
    var bombNode: SKSpriteNode!
    
    override init() {
        super.init()
        
        name = "Bomb"
        emblem = #imageLiteral(resourceName: "Elayis_Machine Guns_0")
        vectors = [Vector(directions: .all, range: 6)]
        
        let attackAmount: Float = 100
        primaryEffects = [Damage(attackAmount, aoeRange: 2, penetrates: true), ForceMove(distance: 1, isAOE: true)]
        description = "Huge explosion on an enemy causing \(attackAmount) damage to surrounding pieces and and knocks them back"
    }
    
    override func preExecute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        guard let target = target else { fatalError() }
        bombNode.position = source.sprite.position
        
        let moveBomb = SKAction.move(to: target.sprite.position, duration: 0.5)
        let scaleBomb = SKAction.scale(by: 2, duration: moveBomb.duration / 2)
        let scaleSequence = SKAction.sequence([scaleBomb, scaleBomb.reversed()])
        let group = SKAction.group([moveBomb, scaleSequence])
        
        source.playAbilityAnimation(self, direction: direction) {
            self.bombNode.run(group) {
                self.bombNode.position = BoardScene.offscreen
                self.execute(source: source, target: target, targetSquare: targetSquare, direction: direction)
            }
        }
    }
}
