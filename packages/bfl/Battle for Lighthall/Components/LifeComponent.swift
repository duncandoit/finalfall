//
//  LifeComponent.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 12/21/24.
//

class LifeComponent
{
    private var maxHealth: Attribute
    private var maxShields: Attribute
    private var maxArmor: Attribute
    private var health: Attribute
    private var shields: Attribute
    private var armor: Attribute
    private var overHealth: Attribute
    private var overArmor: Attribute
    
    init(health: Float, shields: Float, armor: Float, overHealth: Float = 0, overArmor: Float = 0)
    {
        self.maxHealth = HealthAttribute(amount: health > 0 ? health : 1)
        self.maxShields = ShieldsAttribute(amount: shields >= 0 ? shields : 0)
        self.maxArmor = ArmorAttribute(amount: armor >= 0 ? armor : 0)
        self.health = HealthAttribute(amount: health > 0 ? health : 1) // health is always at least 1 to be alive
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
    
    func handleHealing(received: Float, selfTags: [String], instigatorTags: [String])
    {
        guard !(received > 0.0) else { return }
        guard !selfTags.contains(StatusEffect.cursed.name) else { return }
        
        // Starting values
        var remaining  = received
        let oldHealth  = getHealth()
        let oldShields = getShields()
        let oldArmor   = getArmor()
        let maxHealth  = getMaxHealth()
        let maxShields = getMaxShields()
        let maxArmor   = getMaxArmor()

        func healedValue(old oldValue: Float, max maxValue: Float) -> Float
        {
            let attributeHealing = Float.minimum(maxValue - oldValue, remaining)
            let newValue = oldValue + attributeHealing
            remaining -= attributeHealing
            return Float.clamp(newValue, oldValue, maxValue)
        }

        // Health
        if (oldHealth > 0.0 && remaining > 0.0)
        {
            health.setCurrentValue(healedValue(old: oldHealth, max: maxHealth))
        }
        
        // Shields
        if (oldShields > 0.0 && remaining > 0.0)
        {
            shields.setCurrentValue(healedValue(old: oldShields, max: maxShields))
        }
        
        // Armor
        if (oldArmor > 0.0 && remaining > 0.0)
        {
            armor.setCurrentValue(healedValue(old: oldArmor, max: maxArmor))
        }
    }
    
    func getMaxHealth() -> Float
    {
        return maxHealth.getCurrentValue()
    }
    
    func getMaxShields() -> Float
    {
        return maxShields.getCurrentValue()
    }
    
    func getMaxArmor() -> Float
    {
        return maxArmor.getCurrentValue()
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
    
    func setMaxHealth(_ maxHealth: Float)
    {
        self.maxHealth.setCurrentValue(maxHealth)
    }
    
    func setMaxShields(_ maxShields: Float)
    {
        self.maxShields.setCurrentValue(maxShields)
    }
    
    func setMaxArmor(_ maxArmor: Float)
    {
        self.maxArmor.setCurrentValue(maxArmor)
    }
    
    func setHealth(_ health: Float)
    {
        self.health.setCurrentValue(health)
    }
    
    func setShields(_ shields: Float)
    {
        self.shields.setCurrentValue(shields)
    }
    
    func setArmor(_ armor: Float)
    {
        self.armor.setCurrentValue(armor)
    }
    
    func setOverHealth(_ overHealth: Float)
    {
        self.overHealth.setCurrentValue(overHealth)
    }
    
    func setOverArmor(_ overArmor: Float)
    {
        self.overArmor.setCurrentValue(overArmor)
    }
}
