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

@interface DTNodeX : NSManagedObject

@property (nonatomic) int32_t leftCount;
@property (nonatomic) int32_t rightCount;
@property (nonatomic, getter = getBalance) int32_t balance;
@property (nonatomic) float value;
@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) DTNodeX *rightSubNode;
@property (nonatomic, retain) DTNodeX *leftSubNode;

@property (nonatomic, retain) DTNodeX *biggerParent;
@property (nonatomic, retain) DTNodeX *lesserParent;

- (void) addNewNode:(DTNodeX *)x;
- (void) makeBetterBalance;
- (void) terminateAllConnections;

@end

typedef DTNodeX DTNodeY; 