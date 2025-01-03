//
//  LifeComponent.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 12/21/24.
//

class LifeComponent
{
    public static let ARMOR_DMG_MULTIPLIER: Float = 0.8
    
//    private var maxHealth: Attribute
//    private var maxShields: Attribute
//    private var maxArmor: Attribute
    private var health: Attribute
    private var shields: Attribute
    private var armor: Attribute
    private var overHealth: Attribute
    private var overArmor: Attribute
    
    init(health: Float, shields: Float, armor: Float, overHealth: Float = 0, overArmor: Float = 0)
    {
//        self.maxHealth  = Attribute(name: "Max Health",  value: health > 0 ? health : 1)
//        self.maxShields = Attribute(name: "Max Shields", value: shields >= 0 ? shields : 0)
//        self.maxArmor   = Attribute(name: "Max Armor",   value: armor >= 0 ? armor : 0)
        
        self.health     = Attribute(
            name: "Health",
            value: health > 0 ? health : 0,
            maximumValue: health > 0 ? health : 0
        )
        self.shields    = Attribute(
            name: "Shields",
            value: shields >= 0 ? shields : 0,
            maximumValue: shields >= 0 ? shields : 0
        )
        self.armor      = Attribute(
            name: "Armor",
            value: armor >= 0 ? armor : 0,
            maximumValue: armor >= 0 ? armor : 0
        )
        self.overHealth = Attribute(
            name: "Over Health",
            value: overHealth >= 0 ? overHealth : 0,
            maximumValue: overHealth >= 0 ? overHealth : 0
        )
        self.overArmor  = Attribute(
            name: "Over Armor",
            value: overArmor >= 0 ? overArmor : 0,
            maximumValue: overArmor >= 0 ? overArmor : 0
        )
    }
    
    
    /// Takes in the total amount of damage received from some source and apportions it appropriately
    /// to the health, shields, armor, etc. taking into account any stat-based or tag-related
    /// amplification or mitigation to the actual damage received.
    /// - Parameters:
    ///   - received: Total damage output from some source
    ///   - selfTags: Tags relevant to the owner of this LifeComponent
    ///   - instigatorTags: Tags relevant to the source of the damage
    /// - Returns: The actual damage received by this LifeComponent
    func handleDamage(received: Float, selfTags: [String], instigatorTags: [String]) -> Float
    {
        guard received > 0.0 else { return 0.0 }
        guard !selfTags.contains(StatusEffect.invulnerable.name) else { return 0.0 }
        
        var overallDamageMultiplier: Float = 1.0
        
        if selfTags.contains(StatusEffect.weakened.name)
        {
            overallDamageMultiplier += 0.2
        }
        
        if selfTags.contains(StatusEffect.reinforced.name)
        {
            overallDamageMultiplier -= 0.2
        }
        
        // Starting values
        let actualReceived: Float = received * overallDamageMultiplier
        var remaining             = actualReceived
        
        overArmor.commitCurrentToOld()
        overHealth.commitCurrentToOld()
        armor.commitCurrentToOld()
        shields.commitCurrentToOld()
        health.commitCurrentToOld()
        
        // OverArmor
        if (overArmor.getOldValue() > 0.0)
        {
            var attributeMultiplier: Float = LifeComponent.ARMOR_DMG_MULTIPLIER
            //attributeMultiplier += instigatorTags.contains(AbilityEffect.pierceArmor.name) ? 0.2 : 0.0
            damageAttribute(&overArmor, remaining: &remaining, damageMultiplier: attributeMultiplier)
        }
        
        // OverHealth
        if (overHealth.getOldValue() > 0.0 && remaining > 0.0)
        {
            damageAttribute(&health, remaining: &remaining, damageMultiplier: 1.0)
        }

        // Armor
        if (armor.getOldValue() > 0.0 && remaining > 0.0)
        {
            var attributeMultiplier: Float = LifeComponent.ARMOR_DMG_MULTIPLIER
            //attributeMultiplier += instigatorTags.contains(AbilityEffect.pierceArmor.name) ? 0.2 : 0.0
            damageAttribute(&armor, remaining: &remaining, damageMultiplier: attributeMultiplier)
        }

        // Shields
        if (shields.getOldValue() > 0.0 && remaining > 0.0)
        {
            var attributeMultiplier: Float = 1.0
            //attributeMultiplier += instigatorTags.contains(AbilityEffect.drainShields.name) ? 0.2 : 0.0
            damageAttribute(&shields, remaining: &remaining, damageMultiplier: attributeMultiplier)
        }

        // Health
        if (health.getOldValue() > 0.0 && remaining > 0.0)
        {
            damageAttribute(&health, remaining: &remaining, damageMultiplier: 1.0)
            
            if selfTags.contains(StatusEffect.immortal.name)
            {
                if health.getCurrentValue() < 1.0
                {
                    health.setCurrentValue(1.0)
                }
            }
        }
        
        return actualReceived - remaining
    }
    
    func handleHealing(received: Float, selfTags: [String], instigatorTags: [String]) -> Float
    {
        guard !(received > 0.0) else { return 0.0 }
        guard !selfTags.contains(StatusEffect.cursed.name) else { return 0.0 }
        
        var overallHealMultiplier: Float = 1.0
        
        if selfTags.contains(StatusEffect.fortified.name)
        {
            overallHealMultiplier += 0.2
        }
        
        // Starting values
        let actualReceived: Float = received * overallHealMultiplier
        var remaining             = actualReceived
        
        armor.commitCurrentToOld()
        shields.commitCurrentToOld()
        health.commitCurrentToOld()

        // Health
        if (health.getOldValue() > 0.0 && remaining > 0.0)
        {
            healAttribute(&health, remaining: &remaining, healMultiplier: 1.0)
        }
        
        // Shields
        if (shields.getOldValue() > 0.0 && remaining > 0.0)
        {
            healAttribute(&shields, remaining: &remaining, healMultiplier: 1.0)
        }
        
        // Armor
        if (armor.getOldValue() > 0.0 && remaining > 0.0)
        {
            healAttribute(&armor, remaining: &remaining, healMultiplier: 1.0)
        }
        
        return actualReceived - remaining
    }
    
    private func damageAttribute(_ attribute: inout Attribute, remaining: inout Float, damageMultiplier: Float)
    {
        let amountDamaged = Float.minimum(attribute.getOldValue(), (remaining * damageMultiplier))
        let newValue = attribute.getOldValue() - amountDamaged
        remaining -= amountDamaged
        attribute.setCurrentValue(Float.clamp(newValue, 0.0, attribute.getOldValue()))
    }
    
    private func healAttribute(_ attribute: inout Attribute, remaining: inout Float, healMultiplier: Float)
    {
        let amountHealed = Float.minimum(attribute.getMaximumValue() - attribute.getOldValue(), (remaining * healMultiplier))
        let newValue = attribute.getOldValue() + amountHealed
        remaining -= amountHealed
        attribute.setCurrentValue(Float.clamp(newValue, attribute.getOldValue(), attribute.getMaximumValue()))
    }
    
    func getTotalAvailableHealth() -> Float
    {
        return health.getCurrentValue() + shields.getCurrentValue() +
            armor.getCurrentValue() + overHealth.getCurrentValue() +
            overArmor.getCurrentValue()
    }
    
    func getTotalMaxHealth() -> Float
    {
        return health.getMaximumValue() + shields.getMaximumValue() +
            armor.getMaximumValue() + overHealth.getCurrentValue() +
            overArmor.getCurrentValue()
    }
    
    func getMaxHealth() -> Float  { return health.getMaximumValue() }
    func getMaxShields() -> Float { return shields.getMaximumValue() }
    func getMaxArmor() -> Float   { return armor.getMaximumValue() }
    func getHealth() -> Float     { return health.getCurrentValue() }
    func getShields() -> Float    { return shields.getCurrentValue() }
    func getArmor() -> Float      { return armor.getCurrentValue() }
    func getOverHealth() -> Float { return overHealth.getCurrentValue() }
    func getOverArmor() -> Float  { return overArmor.getCurrentValue() }
    
    func setHealthMax(value: Float)  { health.setMaximumValue(value) }
    func setShieldsMax(value: Float) { shields.setMaximumValue(value) }
    func setArmorMax(value: Float)   { armor.setMaximumValue(value) }
    func setHealth(value: Float)     { setAttributeCurrent(&health,     value: value) }
    func setShields(value: Float)    { setAttributeCurrent(&shields,    value: value) }
    func setArmor(value: Float)      { setAttributeCurrent(&armor,      value: value) }
    func setOverHealth(value: Float) { setAttributeCurrent(&overHealth, value: value) }
    func setOverArmor(value: Float)  { setAttributeCurrent(&overArmor,  value: value) }
    
    private func setAttributeCurrent(_ attribute: inout Attribute, value: Float)
    {
        if value > attribute.getMaximumValue()
        {
            attribute.setMaximumValue(value)
        }
        
        attribute.setCurrentValue(value)
    }
}
