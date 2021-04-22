//
//  NSArray+HTUtilities.m
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/21.
//

#import "NSArray+HTDataTrackUtilities.h"
#import "NSFileManager+HTDataTrackUtilities.h"
#import <time.h>
#import <stdarg.h>

#pragma mark StringExtensions

@implementation NSArray (HTDataTrackStringExtensions)

- (NSArray *) htdt_arrayBySortingStrings
{
    NSMutableArray *sort = [NSMutableArray arrayWithArray:self];
    for (id eachitem in self)
        if (![eachitem isKindOfClass:[NSString class]])    [sort removeObject:eachitem];
    return [sort sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSString *) yxtStringValue
{
    return [self componentsJoinedByString:@" "];
}

@end

#pragma mark UtilityExtensions

@implementation NSArray (HTUtilityExtensions)

- (NSArray *) htdt_uniqueMembers
{
    NSMutableArray *copy = [self mutableCopy];// autorelease];
    for (id object in self)
    {
        [copy removeObjectIdenticalTo:object];
        [copy addObject:object];
    }
    return copy;
}

- (NSArray *) htdt_unionWithArray: (NSArray *) anArray
{
    if (!anArray) return self;
    return [[self arrayByAddingObjectsFromArray:anArray] htdt_uniqueMembers];
}

- (NSArray *)htdt_intersectionWithArray:(NSArray *)anArray {
    NSMutableArray *copy = [self mutableCopy];// autorelease];
    for (id object in self)
        if (![anArray containsObject:object])
            [copy removeObjectIdenticalTo:object];
    return [copy htdt_uniqueMembers];
}

- (NSArray *)htdt_intersectionWithSet:(NSSet *)anSet
{
    NSMutableArray *copy = [self mutableCopy];// autorelease];
    for (id object in self)
        if (![anSet containsObject:object])
            [copy removeObjectIdenticalTo:object];
    return [copy htdt_uniqueMembers];
}

// http://en.wikipedia.org/wiki/Complement_(set_theory)
- (NSArray *)htdt_complementWithArray:(NSArray *)anArray
{
    NSMutableArray *copy = [self mutableCopy];// autorelease];
    for (id object in self)
        if ([anArray containsObject:object])
            [copy removeObjectIdenticalTo:object];
    return [copy htdt_uniqueMembers];
}

- (NSArray *)htdt_complementWithSet:(NSSet *)anSet
{
    NSMutableArray *copy = [self mutableCopy];// autorelease];
    for (id object in self)
        if ([anSet containsObject:object])
            [copy removeObjectIdenticalTo:object];
    return [copy htdt_uniqueMembers];
}

@end

#pragma mark Mutable UtilityExtensions
@implementation NSMutableArray (YXTUtilityExtensions)
- (void)htdt_addSafeObject:(id)obj
{
    if (obj)
    {
        [self addObject:obj];
    }
}

- (void)htdt_insertSafeObject:(id)obj atIndex:(NSUInteger)index
{
    if (obj && index<= self.count)
    {
        [self insertObject:obj atIndex:index];
    }
}

+ (NSMutableArray*) htdt_arrayWithSet:(NSSet*)set
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[set count]];
    [set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [array addObject:obj];
    }];
    return array;
}

- (void)htdt_addObjectIfAbsent:(id)object
{
    if (object == nil || [self containsObject:object])
    {
        return;
    }
    
    [self addObject:object];
}

- (NSMutableArray *) htdt_reverse
{
    for (int i=0; i<(floor([self count]/2.0)); i++)
        [self exchangeObjectAtIndex:i withObjectAtIndex:([self count]-(i+1))];
    return self;
}

// Make sure to run srandom([[NSDate date] timeIntervalSince1970]); or similar somewhere in your program
- (NSMutableArray *) htdt_scramble
{
    for (int i=0; i<([self count]-2); i++)
        [self exchangeObjectAtIndex:i withObjectAtIndex:(i+(random()%([self count]-i)))];
    return self;
}

- (NSMutableArray *) htdt_removeFirstObject
{
    [self htdt_removeObjectAtIndex:0];
    return self;
}

- (void)htdt_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (anObject && index < self.count) {
        [self replaceObjectAtIndex:index withObject:anObject];
    }
}

- (void)htdt_removeObjectAtIndex:(NSUInteger)index
{
    if (index < self.count) {
        [self removeObjectAtIndex:index];
    }
}

@end


#pragma mark StackAndQueueExtensions

@implementation NSMutableArray (YXTStackAndQueueExtensions)

- (id) htdt_popObject
{
    if ([self count] == 0) return nil;
    
    id lastObject = [self lastObject];// retain] autorelease];
    [self removeLastObject];
    return lastObject;
}

- (NSMutableArray *) htdt_pushObject:(id)object
{
    if (object) {
        [self addObject:object];
    }
    return self;
}

- (NSMutableArray *) htdt_pushObjects:(id)object,...
{
    if (!object) return self;
    id obj = object;
    va_list objects;
    va_start(objects, object);
    do
    {
        [self addObject:obj];
        obj = va_arg(objects, id);
    } while (obj);
    va_end(objects);
    return self;
}

- (id) htdt_pullObject
{
    if ([self count] == 0) return nil;
    
    id firstObject = [self objectAtIndex:0];// retain] autorelease];
    [self removeObjectAtIndex:0];
    return firstObject;
}

- (NSMutableArray *)htdt_push:(id)object
{
    return [self htdt_pushObject:object];
}

- (id) htdt_pop
{
    return [self htdt_popObject];
}

- (id) htdt_pull
{
    return [self htdt_pullObject];
}

- (void)htdt_enqueueObjects:(NSArray *)objects
{
    for (id object in [objects reverseObjectEnumerator]) {
        [self insertObject:object atIndex:0];
    }
}

@end


@implementation NSArray (HTPSLib)

- (id)htdt_objectUsingPredicate:(NSPredicate *)predicate {
    NSArray *filteredArray = [self filteredArrayUsingPredicate:predicate];
    if (filteredArray) {
        return [filteredArray firstObject];
    }
    return nil;
}

- (BOOL)htdt_isEmpty
{
    return [self count] == 0 ? YES : NO;
}

@end

@implementation NSArray (HTExtendedArray)

- (BOOL)htdt_saveToDocumentsPathFile:(NSString *)path
{
    if (path)
    {
        return [self writeToFile:htdt_DocumentFileWithName(path) atomically:NO];
    }
    return NO;
}

+ (NSArray *)htdt_loadArrayFromDocumentsPath:(NSString *)path
{
    if (path)
    {
        return [NSArray arrayWithContentsOfFile:htdt_DocumentFileWithName(path)];
    }
    return nil;
}

@end
