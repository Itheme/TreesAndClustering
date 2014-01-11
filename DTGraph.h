//
//  DTGraph.h
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTNodeX;

@interface DTGraph : NSManagedObject

@property (nonatomic, retain) DTNodeX *rootNode;

- (void) startBalancingInContext:(NSManagedObjectContext *)context NodeEntityName:(NSString *)nodeEntityName;
- (BOOL) iterateBalancing:(NSUInteger) times;

@end
