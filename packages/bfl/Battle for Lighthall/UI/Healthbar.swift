//
//  Healthbar.swift
//  BoardGame
//
//  Created by Zachary Duncan on 2/27/21.
//

import UIKit

class Healthbar
{
    private var life = LifeComponent(health: 1, shields: 0, armor: 0, overHealth: 0, overArmor: 0)
    
    var barView: UIView = UIView()
    private var borderWidth: CGFloat = 2
    private let height: CGFloat = 12
    
    private let segmentStack: UIStackView = UIStackView()
    private var segments: [[UIView]] = []
    private var segmentSpacing: CGFloat { return onHUD ? 2 : 0 }
    private let segmentValue: Float = 25.0
    
    private var onHUD: Bool = false
    
    /// Required to properly connect a Healthbar to a Piece
    func set(life: LifeComponent, color: UIColor, onHUD: Bool = false)
    {
        self.life = life
        self.onHUD = onHUD
        
        if !onHUD
        {
            barView.backgroundColor = color
            barView.addShadow(radius: 3, offsetY: 1, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.468389448))
        }
        else
        {
            borderWidth = 0
        }
    }
    
    func createUI()
    {
        barView.roundCorners(radius: 3)
        segmentStack.roundCorners(radius: 2)
        
        var segmentCount: Float
        segmentCount = (life.getMaxHealth() + life.getMaxShields()) / segmentValue
        
        let width = barView.frame.width - (borderWidth * 2)
        let height = barView.frame.height - (borderWidth * 2)
        
        segmentStack.frame = CGRect(x: borderWidth, y: borderWidth, width: width, height: height)
        segmentStack.spacing = segmentSpacing
        segmentStack.alignment = .fill
        segmentStack.distribution = .fillEqually
        segmentStack.axis = .horizontal
        segmentStack.clipsToBounds = true
        
        barView.addSubview(segmentStack)
        
        // FIX IMMEDIATELY: TODO: This needed to be fixed
//        for _ in 0 ..< segmentCount
//        {
//            addSegmentContainers()
//        }
//        
//        barView.layoutIfNeeded()
//        
//        for i in 0 ..< segmentCount
//        {
//            addSegment(to: segmentStack.arrangedSubviews[i])
//        }
        
        update(updatedLife: life)
    }
    
    func reset() {
        for view in segmentStack.arrangedSubviews
        {
            view.removeFromSuperview()
        }
        segments = []
    }
    
    private func addSegmentContainers()
    {
        let containerSegment = UIView()
        containerSegment.roundCorners(radius: onHUD ? 1 : 0)
        containerSegment.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15)
        containerSegment.clipsToBounds = true
        segmentStack.addArrangedSubview(containerSegment)
    }
    
    private func addSegment(to container: UIView)
    {
        let health = UIView()
        health.frame = CGRect(x: 0, y: 0, width: container.frame.width, height: container.frame.height)
        health.backgroundColor = .health
        
        let shield = UIView()
        shield.frame = CGRect(x: container.frame.width, y: 0, width: 0, height: container.frame.height)
        shield.backgroundColor = .shield
        
        container.addSubview(health)
        container.addSubview(shield)
        segments.append([health, shield])
    }
    
    func update(frame: CGRect)
    {
        barView.updateFrame(x: frame.minX, y: frame.minY, width: frame.width, height: onHUD ? frame.height : height)
    }
    
    func update(updatedLife: LifeComponent, animated: Bool = true)
    {
        let healthChange = updatedLife.getHealth() + updatedLife.getShields() < life.getHealth() + life.getShields()
        
        life.setMaxHealth(updatedLife.getMaxHealth())
        life.setMaxShields(updatedLife.getMaxShields())
        life.setMaxArmor(updatedLife.getMaxArmor())
        life.setHealth(updatedLife.getHealth())
        life.setShields(updatedLife.getShields())
        life.setArmor(updatedLife.getArmor())
        life.setOverHealth(updatedLife.getOverHealth())
        life.setOverArmor(updatedLife.getOverArmor())
        
        var remainingHealth = life.getHealth()
        var remainingShield = life.getShields()
        
        
        var i = 0
        for segment in segments
        {
            let healthChunk = segment[0]
            let shieldChunk = segment[1]
            
            let healthValue = remainingHealth > segmentValue ? segmentValue : remainingHealth
            let healthWidth = segmentWidthFor(value: healthValue, container: healthChunk.superview!)
            
            let remainingSegmentValue = segmentValue - healthValue
            let shieldValue = remainingSegmentValue > remainingShield ? remainingShield : remainingSegmentValue
            let shieldWidth = segmentWidthFor(value: shieldValue, container: shieldChunk.superview!)
            
            if !animated
            {
                healthChunk.updateFrame(width: healthWidth)
                shieldChunk.updateFrame(x: healthWidth, width: shieldWidth)
            }
            else if healthChange
            {
                let oldWidth = healthChunk.width + shieldChunk.width
                healthChunk.updateFrame(width: healthWidth)
                shieldChunk.updateFrame(x: healthWidth, width: shieldWidth)
                let newWidth = healthChunk.width + shieldChunk.width
                damageAnimation(oldWidth: oldWidth, newWidth: newWidth, fullWidth: healthChunk.superview!.width, index: i)
            }
            else
            {
                healAnimation
                {
                    healthChunk.updateFrame(width: healthWidth)
                    shieldChunk.updateFrame(x: healthWidth, width: shieldWidth)
                }
            }
            
            remainingHealth -= healthValue
            remainingHealth = remainingHealth >= 0 ? remainingHealth : 0
            remainingShield -= shieldValue
            remainingShield = remainingShield >= 0 ? remainingShield : 0
            
            i += 1
        }
    }
    
    private func damageAnimation(oldWidth: CGFloat, newWidth: CGFloat, fullWidth: CGFloat, index i: Int)
    {
        let blipFrame = CGRect(x: (fullWidth * CGFloat(i)) + newWidth + (CGFloat(i) * segmentSpacing) + borderWidth,
                               y: borderWidth,
                               width: (oldWidth - newWidth),
                               height: height - (borderWidth * 2))
        
        let blip = UIView(frame: blipFrame)
        blip.backgroundColor = .damage
        barView.addSubview(blip)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn)
        {
            blip.frame = CGRect(x: blipFrame.minX,
                                y: blipFrame.minY - 10,
                                width: blipFrame.width,
                                height: blipFrame.height + 20)
        }
        completion:
        { finished in
            UIView.animate(withDuration: 0.2)
            {
                blip.alpha = 0
            }
            completion:
            { _ in
                blip.removeFromSuperview()
            }
        }
    }
    
    private func healAnimation(_ frameAdjustment: @escaping ()->Void)
    {
        EventQueue.sync.pushAndWait
        {
            UIView.animate(withDuration: 0.6)
            {
                frameAdjustment()
            }
            completion:
            { finished in
                EventQueue.sync.completeTop()
            }
        }
    }
    
    private func segmentWidthFor(value: Float, container: UIView) -> CGFloat
    {
        return container.frame.width * CGFloat(value > segmentValue ? segmentValue : value) / CGFloat(segmentValue)
    }
}
