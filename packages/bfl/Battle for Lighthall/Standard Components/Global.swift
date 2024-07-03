//
//  Global.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 4/19/21.
//

import UIKit

class BFL {
    class Color {
        // MARK: - Game Palette
        
        static let background: UIColor = #colorLiteral(red: 0.5496664528, green: 0.5495570286, blue: 0.5547392713, alpha: 1)
        static let grey: UIColor = #colorLiteral(red: 0.9176912308, green: 0.9175085425, blue: 0.9261605144, alpha: 1)
        static let darkgrey: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.7494625066)
        static let orange: UIColor = #colorLiteral(red: 0.8905742764, green: 0.6334295869, blue: 0.2349869907, alpha: 1)
        static let blue: UIColor = #colorLiteral(red: 0.2087345719, green: 0.5547905564, blue: 0.9997175336, alpha: 1)
        static let dark: UIColor = #colorLiteral(red: 0.1882352941, green: 0.2392156863, blue: 0.3333333333, alpha: 1)
        static let light: UIColor = #colorLiteral(red: 0.9999071956, green: 1, blue: 0.999881804, alpha: 1)
        
        // MARK: - UI Element Colors
        
        static var menuOption: UIColor { return background + BFL.selectionColorMod - 0.1 }
    }
    
    class Font {
        static let title: UIFont = UIFont.systemFont(ofSize: 55, weight: .black)
        static let header: UIFont = UIFont.systemFont(ofSize: 30, weight: .heavy)
        static let header2: UIFont = UIFont.systemFont(ofSize: 25, weight: .bold)
        static let header3: UIFont = UIFont.systemFont(ofSize: 20, weight: .medium)
        static let subtitle: UIFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
        static let body: UIFont = UIFont.systemFont(ofSize: 20, weight: .regular)
    }
    
    class Emblem {
        // MARK: - Game Modes
        static let attrition = UIImage(systemName: "arrowtriangle.forward.fill")!
        
        // MARK: - UI
        static let back = UIImage(systemName: "arrow.backward.circle")!
        
        // MARK: - Ability Usage
        static let cooldown = UIImage(systemName: "timer")!
        static let allDirections = UIImage(systemName: "arrow.triangle.2.circlepath")!
        static let lateralDirections = UIImage(systemName: "arrow.up.and.down.and.arrow.left.and.right")!
        static let diagonalDirections = UIImage(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")!
        static let noDirection = UIImage(systemName: "dot.circle")!
        
        // MARK: - Effects
    }
    
    struct SceneDepth {
        static let squareNode:  CGFloat = 0
        static let waypoint:    CGFloat = 1
        static let heroIdle:    CGFloat = 2
        static let heroActive:  CGFloat = 3
        static let target:      CGFloat = 4
    }
    
    // MARK: - Misc Values
    
    /// The amount the color of a UI element is modified on user interaction
    static let selectionColorMod: Double = 0.15
    
    /// The standard roundness of certain UI elements
    static let cornerRadius: CGFloat = 5
}
