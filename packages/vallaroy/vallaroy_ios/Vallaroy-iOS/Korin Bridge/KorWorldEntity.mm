//
//  KorWorldEntity.mm
//  Vallaroy-iOS
//
//  Created by Zachary Duncan on 7/1/24.
//

#import <Foundation/Foundation.h>

#import "KorWorldEntity.hpp"
#import "korin/world-entity.h"

@interface KorWorldEntity () {
    std::shared_ptr<korin::WorldEntity> entity;
}

@end

@implementation KorWorldEntity

- (instancetype)initWithX:(float)x
                        y:(float)y
                    width:(float)width
                   height:(float)height
                    scale:(float)scale {
//                 texture:(NSString *)texture {
    self = [super init];
    if (self) {
        entity = std::make_shared<korin::WorldEntity>(x, y, width, height, scale); //, [texture UTF8String]);
    }
    return self;
}

- (instancetype)initWithEntity:(std::shared_ptr<korin::WorldEntity>)entity {
    self = [super init];
    if (self) {
        self->entity = entity;
    }
    return self;
}

- (void)update:(float)deltaTime {
    entity->update(deltaTime);
}

- (void)render {
    entity->render();
}

- (float)x {
    return entity->getX();
}

- (void)setX:(float)x {
    entity->setX(x);
}

- (float)y {
    return entity->getY();
}

- (void)setY:(float)y {
    entity->setY(y);
}

- (float)width {
    return entity->getWidth();
}

- (void)setWidth:(float)width {
    entity->setWidth(width);
}

- (float)height {
    return entity->getHeight();
}

- (void)setHeight:(float)height {
    entity->setHeight(height);
}

- (float)scale {
    return entity->getScale();
}

- (void)setScale:(float)scale {
    entity->setScale(scale);
}

//- (NSString *)texture {
//    return [NSString stringWithUTF8String:entity->getTexture().c_str()];
//}

//- (void)setTexture:(NSString *)texture {
//    entity->setTexture([texture UTF8String]);
//}

- (std::shared_ptr<korin::WorldEntity>)getEntity {
    return entity;
}

@end
