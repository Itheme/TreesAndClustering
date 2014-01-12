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
@property (nonatomic, readonly) NSString *preferedNodeEntityName;
@property (nonatomic, readonly) NSMutableArray *unbalancedNodes;

/*!
 @abstract Starting balancing process
 @discussion Method allocates local allNodes array property, which contains all nodes associated with this graph
 @param context - data model context
 */
- (void) startBalancingInContext:(NSManagedObjectContext *)context;

/*!
 @abstract Performs N (times) balancing iterations
 @discussion Method uses nodes array prepared in startBalancingInContext: method. Balancing is made by median.
 @param times - maximum number of balancing iterations. If graph will be fully balanced 
 */
- (BOOL) iterateBalancing:(NSNumber *) times;

/*!
 @abstract Cancels balancing process
 @discussion Assigns all unbalanced nodes randomly
 */
- (void) cancelBalancing;

- (id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context;

@end
