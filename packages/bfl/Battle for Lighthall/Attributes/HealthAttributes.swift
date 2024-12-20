//
//  HealthAttributes.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 12/19/24.
//

class HealthAttribute: Attribute
{
    init(amount: Float)
    {
        super.init(name: "Health", value: amount)
    }
}

class ShieldsAttribute: Attribute
{
    init(amount: Float)
    {
        super.init(name: "Shields", value: amount)
    }
}

class ArmorAttribute: Attribute
{
    init(amount: Float)
    {
        super.init(name: "Armor", value: amount, multiplier: 1.5)
    }
}

class OverHealthAttribute: Attribute
{
    init(amount: Float)
    {
        super.init(name: "OverHealth", value: amount)
    }
}

class OverArmorAttribute: Attribute
{
    init(amount: Float)
    {
        super.init(name: "OverArmor", value: amount, multiplier: 1.5)
    }
}
