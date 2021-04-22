//
//  NSObject+HTTAssociatedObject.m
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/6.
//

#import "NSObject+HTDataTrackTAssociatedObject.h"

@implementation NSObject (HTDataTrackTAssociatedObject)
- (id)htdt_objectWithAssociatedKey:(void *)key
{
    return objc_getAssociatedObject(self, key);
}

- (void)htdt_setObject:(id)object forAssociatedKey:(void *)key retained:(BOOL)retain
{
    objc_setAssociatedObject(self, key, object, retain?OBJC_ASSOCIATION_RETAIN_NONATOMIC:OBJC_ASSOCIATION_ASSIGN);
}

- (void)htdt_setObject:(id)object forAssociatedKey:(void *)key associationPolicy:(objc_AssociationPolicy)policy
{
    objc_setAssociatedObject(self, key, object, policy);
}

@end
