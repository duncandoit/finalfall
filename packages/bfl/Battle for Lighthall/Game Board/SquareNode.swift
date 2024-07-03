//
//  SquareNode.swift
//  BoardGame
//
//  Created by Zachary Duncan on 2/8/21.
//

import SpriteKit

class SquareNode: SKSpriteNode {
    var hero: Piece?
    var deployable: Piece?
    
    var waypoint: SKSpriteNode? {
        didSet {
            waypoint?.anchorPoint = CGPoint(x: 0, y: 1)
            waypoint?.position = anchorPoint
            waypoint?.zPosition = BFL.SceneDepth.waypoint
            waypoint?.size = size
        }
    }
    
    var target: SKSpriteNode? {
        didSet {
            target?.anchorPoint = CGPoint(x: 0, y: 1)
            target?.position = anchorPoint
            target?.zPosition = BFL.SceneDepth.target
            target?.size = size
        }
    }
    
    var isTraversable = false {
        didSet {
            if isTraversable {
                if waypoint == nil {
                    waypoint = SKSpriteNode(imageNamed: "waypoint")
                    addChild(waypoint!)
                }
            } else {
                waypoint?.removeFromParent()
                waypoint = nil
            }
        }
    }
    
    var isEnemyTarget = false {
        didSet {
            if isEnemyTarget {
                if target == nil { setTarget() }
            } else {
                target?.removeFromParent()
                target = nil
            }
        }
    }
    
    var isFriendlyTarget = false {
        didSet {
            if isFriendlyTarget {
                if target == nil { setTarget() }
            } else {
                target?.removeFromParent()
                target = nil
            }
        }
    }
    
    var isDeployable = false {
        didSet {
            if isDeployable {
                if deployable != nil {
                    isDeployable = false
                    return
                }
                
                if target == nil {
                    target = SKSpriteNode(imageNamed: "deployTarget_0")
                    addChild(target!)
                    
                    var textures: [SKTexture] = []
                    
                    for i in 0 ... 2 {
                        textures.append(SKTexture(imageNamed: "deployTarget_\(i)"))
                    }
                    
                    let animation = SKAction.animate(with: textures, timePerFrame: 0.2)
                    let repeatForever = SKAction.repeatForever(animation)
                    target?.run(repeatForever)
                }
            } else {
                target?.removeFromParent()
                target = nil
            }
        }
    }
    
    private func setTarget() {
        target = SKSpriteNode(imageNamed: isFriendlyTarget ? "friendlyTarget" : "enemyTarget")
        addChild(target!)
        
        let moveUp = SKAction.moveBy(x: 0, y: height / 3, duration: 0.5)
        moveUp.timingMode = .easeOut
        let sequence = SKAction.sequence([moveUp, moveUp.reversed()])
        let repeatForever = SKAction.repeatForever(sequence)
        target?.run(repeatForever)
    }
    
    var up: SquareNode?
    var down: SquareNode?
    var left: SquareNode?
    var right: SquareNode?
    
    var columnIndex: Int = 1
    var rowIndex: Int = 1
    
    var baseColor: UIColor = .white
    
    func direction(by stride: Int, direction: Direction) -> SquareNode? {
        var newNode: SquareNode?
        
        if stride > 0 {
            switch direction {
            case .up:
                newNode = up
            case .upRight:
                newNode = up?.right
            case .right:
                newNode = right
            case .downRight:
                newNode = down?.right
            case .down:
                newNode = down
            case .downLeft:
                newNode = down?.left
            case .left:
                newNode = left
            case .upLeft:
                newNode = up?.left
            default:
                newNode = nil
            }
            
            newNode = newNode?.direction(by: stride - 1, direction: direction)
        } else if stride < 0 {
            switch direction {
            case .up:
                newNode = down
            case .upRight:
                newNode = down?.left
            case .right:
                newNode = left
            case .downRight:
                newNode = up?.left
            case .down:
                newNode = up
            case .downLeft:
                newNode = up?.right
            case .left:
                newNode = right
            case .upLeft:
                newNode = down?.right
            default:
                newNode = nil
            }
            
            newNode = newNode?.direction(by: stride + 1, direction: direction)
        } else {
            newNode = self
        }
        
        return newNode
    }
    
    func up(by stride: Int) -> SquareNode? {
        return direction(by: stride, direction: .up)
    }
    
    func down(by stride: Int) -> SquareNode? {
        return direction(by: stride, direction: .down)
    }
    
    func left(by stride: Int) -> SquareNode? {
        return direction(by: stride, direction: .left)
    }
    
    func right(by stride: Int) -> SquareNode? {
        return direction(by: stride, direction: .right)
    }
    
    // MARK: - CustomStringConvertable Methods
    
    override var description: String { "SquareNode row:\(rowIndex) column:\(columnIndex)" }
}
