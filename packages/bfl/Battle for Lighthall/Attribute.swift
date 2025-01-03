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
        commitCurrentToOld()
        
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
        oldValue = value > 0.0 ? value : 0.0
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
    
    func commitCurrentToOld()
    {
        setOldValue(getCurrentValue())
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
