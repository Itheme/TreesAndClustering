//
//  DTNodeX.h
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTNodeX;
@class DTCluster;

typedef DTNodeX DTNodeY;

// A binary tree node
@interface DTNodeX : NSManagedObject

// count of all nodes attached to leftSubNode property
@property (nonatomic) int32_t leftCount;

// count of all nodes attached to rightSubNode property
@property (nonatomic) int32_t rightCount;

// ABS(leftCount - rightCount) - attribute that shows how unbalanced is this node
@property (nonatomic, getter = getBalance) int32_t balance;

// value is node's X for NodeX and node's y for NodeY
@property (nonatomic) float value;

// just some fake data
@property (nonatomic, retain) NSString *data;
// just some fake name
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) DTNodeX *rightSubNode;
@property (nonatomic, retain) DTNodeX *leftSubNode;

@property (nonatomic, retain) DTNodeX *biggerParent;
@property (nonatomic, retain) DTNodeX *lesserParent;

// corresponding NodeY for NodeX
@property (nonatomic, retain) DTNodeY *pair;

// cluster for this node
@property (nonatomic, retain) DTCluster *cluster;

/*!
 @abstract Adds new node to this node or to some of it's children
 @discussion Recursively iterates his node and all of it's children untill the proper position will be found
 @param x - node to be added
 */
- (void) addNewNode:(DTNodeX *)x;

/*!
 @abstract Obsolete method from previous balancing algorithm
 @discussion Method tries to minimize balance property value by assigning one of nodes children instead of self to it's parent if possible
 */
- (void) makeBetterBalance;

/*!
 @abstract resets subnodes connections
 @discussion Nullifies leftSubNode and rightSubNode
 */
- (void) terminateAllConnections;

@end
