//
//  KorWorldEntity.hpp
//  Vallaroy-iOS
//
//  Created by Zachary Duncan on 7/1/24.
//

#ifndef KorWorldEntity_hpp
#define KorWorldEntity_hpp

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <memory>

namespace korin {
    class WorldEntity;
}

@interface KorWorldEntity : NSObject

- (instancetype)initWithX:(float)x
                        y:(float)y
                    width:(float)width
                   height:(float)height
                    scale:(float)scale;
//                 texture:(NSString *)texture;

- (instancetype)initWithEntity:(std::shared_ptr<korin::WorldEntity>)entity;

- (void)update:(float)deltaTime;
- (void)render;
- (std::shared_ptr<korin::WorldEntity>)getEntity;

@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) float width;
@property (nonatomic) float height;
@property (nonatomic) float scale;
//@property (nonatomic, strong) NSString *texture;

@end

#endif /* KorWorldEntity_hpp */
