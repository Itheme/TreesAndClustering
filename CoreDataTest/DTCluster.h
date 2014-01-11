//
//  DTCluster.h
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/12/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTNodeX;

@interface DTCluster : NSManagedObject

@property (nonatomic) float centerX;
@property (nonatomic) float centerY;
@property (nonatomic) float angle;
@property (nonatomic) float length;
@property (nonatomic, retain) NSSet *nodes;

/*!
 @abstract tries to self organize
 @discussion magic
 @param model context
 @param maximum distance to cover by one iteration
 */

- (BOOL)iterateSelfOrganizationInContext:(NSManagedObjectContext *)context DistanceLinit:(float)distanceLimit;

@end

@interface DTCluster (CoreDataGeneratedAccessors)

- (void)addRelationshipObject:(DTNodeX *)value;
- (void)removeRelationshipObject:(DTNodeX *)value;
- (void)addRelationship:(NSSet *)values;
- (void)removeRelationship:(NSSet *)values;

@end
