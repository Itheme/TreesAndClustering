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

// Linear cluster
@interface DTCluster : NSManagedObject

// cluster mean center x
@property (nonatomic) float centerX;

// cluster mean center y
@property (nonatomic) float centerY;

// since the cluster is looking like a line, it has an angle
@property (nonatomic) float angle;

// length of cluster
@property (nonatomic) float length;

// nodes forming this cluster (only NodeX type, since NodeYs could be found through node.pair properties
@property (nonatomic, retain) NSSet *nodes;

/*!
 @abstract tries to self organize
 @discussion magic
 @param model context
 */
- (BOOL)iterateSelfOrganizationInContext:(NSManagedObjectContext *)context;

/*!
 @abstract Take a closest node from a given cluster
 @discussion Method puts closest node from a given cluster into this cluster node list
 @param cluster victim cluster
 @param context - model context
 */
- (void)borrowNodeFrom:(DTCluster *)cluster InContext:(NSManagedObjectContext *)context;

/*!
 @abstract init method
 @param entity - entity of a DTCluster
 @param context - model context
 @param distanceLimit - maximum distance to cover by one iteration
 */
- (id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context DistanceLimit:(float) distanceLimit;

@end

@interface DTCluster (CoreDataGeneratedAccessors)

- (void)addRelationshipObject:(DTNodeX *)value;
- (void)removeRelationshipObject:(DTNodeX *)value;
- (void)addRelationship:(NSSet *)values;
- (void)removeRelationship:(NSSet *)values;

@end

@interface NSArray (DTClusterArray)

- (DTCluster *) closestToCluster:(DTCluster *)cluster;

@end
