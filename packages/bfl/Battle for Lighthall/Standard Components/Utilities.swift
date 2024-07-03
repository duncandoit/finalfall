//
//  Utilities.swift
//  BoardGame
//
//  Created by Zachary Duncan on 2/26/21.
//

import SpriteKit

extension UIColor {
    // MARK: - UI Colors
    static let abilityEnabled: UIColor = #colorLiteral(red: 0.9208778739, green: 0.9251395464, blue: 0.9355565906, alpha: 1)
    static let abilityDisabled: UIColor = #colorLiteral(red: 0.7725490196, green: 0.231372549, blue: 0.1882352941, alpha: 0.8035886069)
    static let abilitySelected: UIColor = .systemYellow
    static let abilityUltimate: UIColor = .systemTeal
    static let shield: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    static let health: UIColor = .white
    
    // MARK: - Effect Colors
    static let damage: UIColor = #colorLiteral(red: 1, green: 0.1980154714, blue: 0, alpha: 1)
    static let healing: UIColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    static let poisoned: UIColor = .systemPurple
    static let frozen: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    static let sleeping: UIColor = .systemTeal
    static let immobilized: UIColor = .brown
    static let burning: UIColor = .systemRed
    static let slowed: UIColor = .darkGray
    static let stunned: UIColor = .systemYellow
    static let cursed: UIColor = .black
    static let disabled: UIColor = .gray
    static let amplified: UIColor = #colorLiteral(red: 0.6762521863, green: 0.2822794914, blue: 1, alpha: 1)
    static let speed: UIColor = #colorLiteral(red: 0.2692326009, green: 0.8891395926, blue: 0.5993961096, alpha: 1)
    static let immortal: UIColor = .health
    static let unstoppable: UIColor = #colorLiteral(red: 0.4392156899, green: 0.01176470611, blue: 0.1921568662, alpha: 1)
    
    // MARK: - Team Colors
    static let teamBlue: UIColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    static let teamRed: UIColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 1)
    
    // MARK: - Board Colors
    static let squareLight: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
    static let squareDark: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.25)
    static let squareInMovementRange: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.5)
    static let squareInAbilityRange: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3)
    static let squareEnemyTarget: UIColor = .teamRed.opacity(0.5)
    static let squareFriendlyTarget: UIColor = .teamBlue.opacity(0.3)
    static let squareDeployTarget: UIColor = #colorLiteral(red: 0.9764705896, green: 0.979894757, blue: 0, alpha: 0.5)
}

extension UIImage {
    static let dps: UIImage = UIImage(named: "dps")!
    static let tank: UIImage = UIImage(named: "tank")!
    static let healer: UIImage = UIImage(named: "healer")!
}

extension CGPoint {
    func isInBounds(of view: UIView) -> Bool {
        return view.frame.minX < x &&
                view.frame.maxX > x &&
                view.frame.minY < y &&
                view.frame.maxY > y
    }
    
    func isInBounds(of spriteNode: SKSpriteNode) -> Bool {
        return spriteNode.frame.minX < x &&
            spriteNode.frame.maxX > x &&
            spriteNode.frame.minY < y &&
            spriteNode.frame.maxY > y
    }
}

extension UIView {
    var width: CGFloat { frame.width }
    var height: CGFloat { frame.height }
    var minX: CGFloat { frame.minX }
    var midX: CGFloat { frame.midX }
    var maxX: CGFloat { frame.maxX }
    var minY: CGFloat { frame.minY }
    var midY: CGFloat { frame.midY }
    var maxY: CGFloat { frame.maxY }

    func updateFrame(x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil) {
        let newX = x == nil ? frame.minX : x!
        let newY = y == nil ? frame.minY : y!
        let newWidth = width == nil ? frame.width : width!
        let newHeight = height == nil ? frame.height : height!
        
        frame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
    }
}

extension SKSpriteNode {
    var width: CGFloat { frame.width }
    var height: CGFloat { frame.height }
    var minX: CGFloat { frame.minX }
    var midX: CGFloat { frame.midX }
    var maxX: CGFloat { frame.maxX }
    var minY: CGFloat { frame.minY }
    var midY: CGFloat { frame.midY }
    var maxY: CGFloat { frame.maxY }
    
    static func texturesFrom(atlasNamed atlasName: String) -> [SKTexture] {
        let atlas = SKTextureAtlas(named: atlasName)
        var textures: [SKTexture] = []
        
        for i in 0 ..< atlas.textureNames.count {
            let texture = SKTexture(imageNamed: atlasName + "\(i)")
            
            // This removes the blurry antialiasing on pixel art
            texture.filteringMode = .nearest
            textures.append(texture)
        }
        
        return textures
    }
    
    func aspectScale(toFill fillSize: CGSize) {
        if let texture = texture {
            size = texture.size()

            let verticalRatio = fillSize.height / texture.size().height
            let horizontalRatio = fillSize.width /  texture.size().width
            let scaleRatio = horizontalRatio > verticalRatio ? horizontalRatio : verticalRatio

            setScale(scaleRatio)
        }
    }
    
    func aspectScale(toFit fitSize: CGSize) {
        if let texture = texture {
            size = texture.size()

            let verticalRatio = fitSize.height / texture.size().height
            let horizontalRatio = fitSize.width /  texture.size().width
            let scaleRatio = horizontalRatio > verticalRatio ? verticalRatio : horizontalRatio

            setScale(scaleRatio)
        }
    }
    
    func addGlow(radius: Float = 30) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius":radius])
    }
}

struct Vector {
    var directions: Direction
    var range: Int
}

struct Direction: OptionSet {
    let rawValue: UInt8
    
    static let up =         Direction(rawValue: 1 << 0)
    static let upRight =    Direction(rawValue: 1 << 1)
    static let right =      Direction(rawValue: 1 << 2)
    static let downRight =  Direction(rawValue: 1 << 3)
    static let down =       Direction(rawValue: 1 << 4)
    static let downLeft =   Direction(rawValue: 1 << 5)
    static let left =       Direction(rawValue: 1 << 6)
    static let upLeft =     Direction(rawValue: 1 << 7)
    static let none =       Direction([])
    
    static let diagonal:    Direction =  [upRight, downRight, downLeft, upLeft]
    static let lateral:     Direction =  [up, right, down, left]
    static let all:         Direction =  [up, upRight, right, downRight, down, downLeft, left, upLeft]
    static let each:       [Direction] = [up, upRight, right, downRight, down, downLeft, left, upLeft]
}
