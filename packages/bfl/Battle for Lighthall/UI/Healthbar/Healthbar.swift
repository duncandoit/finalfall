//
//  Healthbar.swift
//  BoardGame
//
//  Created by Zachary Duncan on 2/27/21.
//

import UIKit

struct HealthbarConfig
{
    let segmentValue: Float
    let segmentSpacing: CGFloat
    
    let borderWidth: CGFloat
    let height: CGFloat
    let shadowRadius: CGFloat
    let cornerRadius: CGFloat
    let chunkColors: [UIColor]
    
    static let floating = HealthbarConfig(
        segmentValue: 25,
        segmentSpacing: 0,
        borderWidth: 2,
        height: 12,
        shadowRadius: 3,
        cornerRadius: 0,
        chunkColors: [.health, .shields, .armor, .overHealth, .overArmor]
    )
    
    static let hud = HealthbarConfig(
        segmentValue: 25,
        segmentSpacing: 2,
        borderWidth: 2,
        height: 12,
        shadowRadius: 0,
        cornerRadius: 1,
        chunkColors: [.health, .shields, .armor, .overHealth, .overArmor]
    )
}

class Healthbar
{
    var barView: UIView = UIView()
    
    private var life = LifeComponent(health: 0, shields: 0, armor: 0, overHealth: 0, overArmor: 0)
    
    private let segmentStack: UIStackView = UIStackView()
    private var segmentViews: [UIView] = []
    private var segmentChunkViews: [[UIView]] = []
    private var chunkWidthConstraints: [[NSLayoutConstraint]] = []
    private var chunkLeadingConstraints: [[NSLayoutConstraint]] = []
    
    private var config: HealthbarConfig = HealthbarConfig.floating
    
    /// Required to properly connect a Healthbar to a Piece
    func set(life: LifeComponent, color: UIColor, config: HealthbarConfig = .floating)
    {
        self.config = config
        copyLife(life)
        
        barView.backgroundColor = color
        barView.addShadow(radius: config.shadowRadius, offsetY: 1, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.468389448))
    }
    
    func constructHealthbarView()
    {
        barView.roundCorners(radius: 3)
        segmentStack.roundCorners(radius: 2)
        
        segmentStack.translatesAutoresizingMaskIntoConstraints = false
        segmentStack.spacing = config.segmentSpacing
        segmentStack.alignment = .fill
        segmentStack.distribution = .fillProportionally
        segmentStack.axis = .horizontal
        segmentStack.clipsToBounds = true
        barView.addSubview(segmentStack)
        
        NSLayoutConstraint.activate([
            segmentStack.leadingAnchor.constraint(equalTo: barView.leadingAnchor, constant: config.borderWidth),
            segmentStack.trailingAnchor.constraint(equalTo: barView.trailingAnchor, constant: -config.borderWidth),
            segmentStack.topAnchor.constraint(equalTo: barView.topAnchor, constant: config.borderWidth),
            segmentStack.bottomAnchor.constraint(equalTo: barView.bottomAnchor, constant: -config.borderWidth)
        ])
        
        constructSegmentViews()
        updateLife(life)
    }
    
    private func constructSegmentViews()
    {
        destroyHealthbarViews()
        
        let segmentCount = Int((life.getTotalMaxHealth() / config.segmentValue).rounded(.up))
        var remainingHealth = life.getTotalMaxHealth()
        
        // Create segement views
        for s in 0 ..< segmentCount
        {
            let actualSegmentValue = Float.minimum(config.segmentValue, life.getTotalMaxHealth() - Float(s) * config.segmentValue)
            remainingHealth -= actualSegmentValue
            
            let segmentView = UIView()
            segmentView.roundCorners(radius: config.cornerRadius)
            segmentView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15)
            segmentView.clipsToBounds = true
            segmentView.updateFrame(width: CGFloat(actualSegmentValue))
            
            segmentViews.append(segmentView)
            segmentChunkViews.append([])
            segmentStack.addArrangedSubview(segmentView)
            
            var segmentChunkConstraints: [NSLayoutConstraint] = []
            var segmentLeadingConstraints: [NSLayoutConstraint] = []
            
            // Create segment chunk views
            for (c, chunkColor) in config.chunkColors.enumerated()
            {
                let chunkView = UIView()
                chunkView.translatesAutoresizingMaskIntoConstraints = false
                chunkView.backgroundColor = chunkColor
                segmentView.addSubview(chunkView)
                segmentChunkViews[s].append(chunkView)
                
                NSLayoutConstraint.activate([
                    chunkView.topAnchor.constraint(equalTo: segmentView.topAnchor),
                    chunkView.bottomAnchor.constraint(equalTo: segmentView.bottomAnchor)
                ])

                let leadingConstraint: NSLayoutConstraint
                if c > 0
                {
                    leadingConstraint = chunkView.leadingAnchor.constraint(equalTo: segmentChunkViews[s][c - 1].trailingAnchor)
                }
                else
                {
                    leadingConstraint = chunkView.leadingAnchor.constraint(equalTo: segmentView.leadingAnchor)
                }
                
                leadingConstraint.isActive = true
                segmentLeadingConstraints.append(leadingConstraint)
                
                let widthConstraint = chunkView.widthAnchor.constraint(equalTo: segmentView.widthAnchor, multiplier: 1)
                widthConstraint.isActive = true
                segmentChunkConstraints.append(widthConstraint)
            }
            
            chunkWidthConstraints.append(segmentChunkConstraints)
            chunkLeadingConstraints.append(segmentLeadingConstraints)
        }
        
        barView.layoutIfNeeded()
    }
    
    func destroyHealthbarViews()
    {
        for view in segmentStack.arrangedSubviews
        {
            view.removeFromSuperview()
        }
        
        chunkWidthConstraints.removeAll()
        chunkLeadingConstraints.removeAll()
        segmentChunkViews.removeAll()
        segmentViews.removeAll()
    }
    
//    func updateLife(_ updatedLife: LifeComponent, animated: Bool = true)
//    {
//        let healthMaxChange = updatedLife.getTotalMaxHealth() - life.getTotalMaxHealth()
//        if healthMaxChange != 0
//        {
//            constructSegmentViews()
//        }
//        
//        copyLife(updatedLife)
//        
//        var totalRemainingChunks: [Float] = [
//            life.getHealth(),
//            life.getShields(),
//            life.getArmor(),
//            life.getOverHealth(),
//            life.getOverArmor()
//        ]
//        
//        print("Starting Chunks: \(totalRemainingChunks)")
//        
//        for (s, segment) in segmentViews.enumerated()
//        {
//            let actualSegmentValue: Float = Float.minimum(config.segmentValue, life.getTotalMaxHealth() - Float(s) * config.segmentValue)
//            var totalSegmentHealth: Float = 0.0
//            var currentChunks: [Float] = []
//            
//            // Fill in the segment's chunks
//            guard chunkWidthConstraints.count > s else { continue }
//            for (c, widthConstraint) in chunkWidthConstraints[s].enumerated()
//            {
//                // Assign the value of each chunk within the segment
//                let segmentDeficit = actualSegmentValue - totalSegmentHealth
//                let chunkValue: Float = Float.clamp(totalRemainingChunks[c], 0.0, segmentDeficit)
////                let chunkValue = (totalRemainingChunks[c] / actualSegmentValue) * segmentDeficit
////                currentChunks.append(Float.clamp(chunkValue, 0.0, segmentDeficit))
//                currentChunks.append(chunkValue)
//                
//                // Track the value added to this segment against the overall total
//                totalSegmentHealth += chunkValue
//                totalRemainingChunks[c] -= chunkValue
//                
//                // Update constraints
//                widthConstraint.constant = segment.frame.width * CGFloat((chunkValue / actualSegmentValue))
//                print("Segment:\(s), Chunk:\(c), Remaining Chunk:\(totalRemainingChunks[c]), Segment Deficit:\(segmentDeficit), Chunk Value:\(chunkValue)")
//            }
//        }
//        
//        print("Ending Chunks: \(totalRemainingChunks)")
//        
//        if animated
//        {
//            UIView.animate(withDuration: 0.2)
//            {
//                self.barView.layoutIfNeeded()
//            }
//        }
//        else
//        {
//            barView.layoutIfNeeded()
//        }
//    }
    
    func updateLife(_ updatedLife: LifeComponent, animated: Bool = true)
    {
        let healthMaxChange = updatedLife.getTotalMaxHealth() - life.getTotalMaxHealth()
        if healthMaxChange != 0
        {
            constructSegmentViews()
        }

        copyLife(updatedLife)

        var totalRemainingChunks: [Float] = [
            life.getHealth(),
            life.getShields(),
            life.getArmor(),
            life.getOverHealth(),
            life.getOverArmor()
        ]

        for (s, segment) in segmentViews.enumerated()
        {
            let actualSegmentValue: Float = Float.minimum(config.segmentValue, life.getTotalMaxHealth() - Float(s) * config.segmentValue)
            var totalSegmentHealth: Float = 0.0

            guard chunkWidthConstraints.count > s else { continue }

            for (c, widthConstraint) in chunkWidthConstraints[s].enumerated()
            {
                let segmentDeficit = actualSegmentValue - totalSegmentHealth
                let chunkValue: Float = Float.clamp(totalRemainingChunks[c], 0.0, segmentDeficit)

                totalSegmentHealth += chunkValue
                totalRemainingChunks[c] -= chunkValue

                // Adjust width proportionally based on the chunk value
                let proportionalWidth = CGFloat(chunkValue / actualSegmentValue)
                widthConstraint.constant = segment.frame.width * proportionalWidth
            }
        }

        if animated
        {
            UIView.animate(withDuration: 0.2)
            {
                self.barView.layoutIfNeeded()
            }
        }
        else
        {
            barView.layoutIfNeeded()
        }
    }
    
    func updateFrame(_ frame: CGRect)
    {
        barView.updateFrame(x: frame.minX, y: frame.minY, width: frame.width, height: config.height)
    }
    
    /// Copies the new LifeComponent's values to the member one.
    /// - Parameter updatedLife: LifeComponent to be copied
    private func copyLife(_ updatedLife: LifeComponent)
    {
        life.setHealthMax(value:  updatedLife.getMaxHealth())
        life.setShieldsMax(value: updatedLife.getMaxShields())
        life.setArmorMax(value:   updatedLife.getMaxArmor())
        life.setHealth(value:     updatedLife.getHealth())
        life.setShields(value:    updatedLife.getShields())
        life.setArmor(value:      updatedLife.getArmor())
        life.setOverHealth(value: updatedLife.getOverHealth())
        life.setOverArmor(value:  updatedLife.getOverArmor())
    }
}
