//
//  KorWorld.mm
//  Vallaroy-iOS
//
//  Created by Zachary Duncan on 7/1/24.
//

#import <Foundation/Foundation.h>

#import "korin/world.h"

#import "KorWorld.hpp"
#import "KorWorldEntity.hpp"

@interface KorWorld () {
    std::shared_ptr<korin::World> world;
}

@end

@implementation KorWorld

- (instancetype)init {
    self = [super init];
    if (self) {
        world = std::make_shared<korin::World>();
    }
    return self;
}

- (void)update:(float)deltaTime {
    world->update(deltaTime);
}

- (void)render {
    world->render();
}

- (void)addEntity:(KorWorldEntity *)entity {
    world->addEntity([entity getEntity]);
}

- (void)removeEntity:(KorWorldEntity *)entity {
    world->removeEntity([entity getEntity]);
}

- (NSArray<KorWorldEntity *> *)getEntities {
    const auto& entities = world->getEntities();
    NSMutableArray<KorWorldEntity *> *result = [NSMutableArray arrayWithCapacity:entities.size()];

    for (const auto& entity : entities) {
        [result addObject:[[KorWorldEntity alloc] initWithEntity:entity]];
    }

    return result;
}

//- (CGPoint)artboardLocationFromTouchLocation:(CGPoint)touchLocation
//                               inArtboard:(CGRect)artboardRect fit:(RiveFit)fit alignment:(RiveAlignment)alignment {
//    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
//                         self.frame.size.width + self.frame.origin.x,
//                         self.frame.size.height + self.frame.origin.y);
//
//    rive::AABB content(artboardRect.origin.x, artboardRect.origin.y,
//                       artboardRect.size.width + artboardRect.origin.x,
//                       artboardRect.size.height + artboardRect.origin.y);
//    
//    auto riveFit = [self riveFit:fit];
//    auto riveAlignment = [self riveAlignment:alignment];
//    
//    rive::Mat2D forward = rive::computeAlignment(riveFit, riveAlignment, frame, content);
//    rive::Mat2D inverse = forward.invertOrIdentity();
//    
//    rive::Vec2D frameLocation(touchLocation.x, touchLocation.y);
//    rive::Vec2D convertedLocation = inverse * frameLocation;
//    
//    return CGPointMake(convertedLocation.x, convertedLocation.y);
//}

@end
