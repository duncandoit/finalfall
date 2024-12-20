//
//  Attribute.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 12/18/24.
//

class Attribute
{
    let name: String
    private var currentValue: Float
    private var oldValue: Float
    private var minimumValue: Float
    private var maximumValue: Float
    private var multiplier: Float
    private var tags: [String] = []
    // Note for future me wanting to implement decay and regen... Do it with Effects!
    
    init
    (
        name: String,
        value: Float,
        minimumValue: Float = 0.0,
        maximumValue: Float = Float.infinity,
        multiplier: Float = 1.0
    )
    {
        self.name = name
        self.currentValue = value
        self.oldValue = 0.0
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.multiplier = multiplier
    }
    
    func getCurrentValue() -> Float
    {
        return currentValue
    }
    
    func setCurrentValue(_ value: Float)
    {
        let value = value > 0.0 ? value : 0.0
        
        if value < minimumValue
        {
            currentValue = minimumValue
        }
        else if value > maximumValue
        {
            currentValue = maximumValue
        }
        else
        {
            self.currentValue = value
        }
    }
    
    func getOldValue() -> Float
    {
        return oldValue
    }
    
    func setOldValue(_ value: Float)
    {
        let value = value > 0.0 ? value : 0.0
        
        if value < minimumValue
        {
            oldValue = minimumValue
        }
        else if value > maximumValue
        {
            oldValue = maximumValue
        }
        else
        {
            oldValue = value
        }
    }
    
    func getMaximumValue() -> Float
    {
        return maximumValue
    }
    
    func setMaximumValue(_ value: Float)
    {
        maximumValue = value > 0.0 ? value : 0.0
        
        if currentValue > maximumValue
        {
            currentValue = maximumValue
        }
    }
    
    func getMinimumValue() -> Float
    {
        return minimumValue
    }
    
    func setMinimumValue(_ value: Float)
    {
        minimumValue = value > 0.0 ? value : 0.0
        
        if currentValue < minimumValue
        {
            currentValue = minimumValue
        }
    }
    
    func getMultiplier() -> Float
    {
        return multiplier
    }
    
    func setMultiplier(_ value: Float)
    {
        multiplier = value > 0.0 ? value : 0.0
    }
    
    func addUniqueTag(_ tag: String)
    {
        if (!tags.contains(tag))
        {
            tags.append(tag)
        }
    }
    
    func addTag(_ tag: String)
    {
        tags.append(tag)
    }
    
    func removeTag(_ tag: String)
    {
        if let index = tags.firstIndex(of: tag)
        {
            tags.remove(at: index)
        }
    }
    
    func removeAllOfTag(_ tag: String)
    {
        tags.removeAll { $0 == tag }
    }
    
    func getTags() -> [String]
    {
        return tags
    }
}

class LifeComponent
{
    private var health: Attribute
    private var shields: Attribute
    private var armor: Attribute
    private var overHealth: Attribute
    private var overArmor: Attribute
    
    init(health: Float, shields: Float, armor: Float, overHealth: Float = 0, overArmor: Float = 0)
    {
        // Ensure that health is always at least 1 to be alive
        self.health = HealthAttribute(amount: health > 0 ? health : 1)
        self.shields = ShieldsAttribute(amount: shields >= 0 ? shields : 0)
        self.armor = ArmorAttribute(amount: armor >= 0 ? armor : 0)
        self.overHealth = OverHealthAttribute(amount: overHealth >= 0 ? overHealth : 0)
        self.overArmor = OverArmorAttribute(amount: overArmor >= 0 ? overArmor : 0)
    }
    
    func handleDamage(received: Float, selfTags: [String], instigatorTags: [String])
    {
        guard received > 0 else { return }
        guard !selfTags.contains("Invulnerable") else { return }

        // Starting values
        var remaining: Float = received
        let oldOverArmor     = overArmor.getCurrentValue()
        let oldOverHealth    = overHealth.getCurrentValue()
        let oldArmor         = armor.getCurrentValue()
        let oldShields       = shields.getCurrentValue()
        let oldHealth        = health.getCurrentValue()
        
        // Tags to implement
        // - Weakened       : Takes more damage
        // - Fortified      : Takes less damage
        
        func damagedValue(_ oldValue: Float) -> Float
        {
            let attributeDamage = Float.minimum(oldValue, remaining)
            let newValue = oldValue - attributeDamage
            remaining -= attributeDamage
            return Float.clamp(newValue, 0.0, oldValue)
        }
        
        // OverArmor
        if (oldOverArmor > 0.0)
        {
            overArmor.setCurrentValue(damagedValue(oldOverArmor));
        }
        
        // OverHealth
        if (oldOverHealth > 0.0 && remaining > 0.0)
        {
            overHealth.setCurrentValue(damagedValue(oldOverHealth));
        }

        // Armor
        if (oldArmor > 0.0 && remaining > 0.0)
        {
            armor.setCurrentValue(damagedValue(oldArmor));
        }

        // Shields
        if (oldShields > 0.0 && remaining > 0.0)
        {
            shields.setCurrentValue(damagedValue(oldShields));
        }

        // Health
        if (oldHealth > 0.0 && remaining > 0.0)
        {
            let damagedHealth = damagedValue(oldHealth)
            
            if selfTags.contains(StatusEffect.immortal.name)
            {
                if damagedHealth < 1.0
                {
                    health.setCurrentValue(1.0)
                }
            }
            else
            {
                health.setCurrentValue(damagedHealth)
            }
        }
    }
    
    func getHealth() -> Float
    {
        return health.getCurrentValue()
    }
    
    func getShields() -> Float
    {
        return shields.getCurrentValue()
    }
    
    func getArmor() -> Float
    {
        return armor.getCurrentValue()
    }
    
    func getOverHealth() -> Float
    {
        return overHealth.getCurrentValue()
    }
    
    func getOverArmor() -> Float
    {
        return overArmor.getCurrentValue()
    }
    
    func getTotalHealth() -> Float
    {
        return health.getCurrentValue() + shields.getCurrentValue() + armor.getCurrentValue() + overHealth.getCurrentValue() + overArmor.getCurrentValue()
    }
}
