//
//  KorWorld.hpp
//  Vallaroy-iOS
//
//  Created by Zachary Duncan on 6/27/24.
//

#ifndef KorWorld_hpp
#define KorWorld_hpp

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KorWorldEntity;

NS_ASSUME_NONNULL_BEGIN

@interface KorWorld : NSObject

- (instancetype)init;

- (void)update:(float)deltaTime;
- (void)render;

- (void)addEntity:(KorWorldEntity *)entity;
- (void)removeEntity:(KorWorldEntity *)entity;
- (const NSArray<KorWorldEntity *> *)getEntities;

@end

NS_ASSUME_NONNULL_END

#endif /* KorWorld_hpp */
