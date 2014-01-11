//
//  DTNodeX.m
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "DTNodeX.h"
#import "DTNodeX.h"


@implementation DTNodeX

@dynamic leftCount, balance, rightCount;
@dynamic value;
@dynamic data;
@dynamic name;
@dynamic biggerParent, lesserParent;
@dynamic leftSubNode, rightSubNode, pair;
@dynamic cluster;

@dynamic lastEffectiveDistance;

- (int32_t) getBalance {
    return ABS(self.leftCount - self.rightCount);
}

- (void) addNewNode:(DTNodeX *)x {
    if (!x) return;
    if (x.value > self.value) {
        if (self.rightSubNode)
            [self.rightSubNode addNewNode:x];
        else {
            self.rightSubNode = x;
            //x.lesserParent = self;
        }
        self.rightCount += 1;
    } else {
        if (self.leftSubNode)
            [self.leftSubNode addNewNode:x];
        else {
            self.leftSubNode = x;
            //x.biggerParent = self;
        }
        self.leftCount += 1;
    }
}

- (void) substituteRightWith:(DTNodeX *)newNode {
    self.rightSubNode.lesserParent = nil;
    self.rightSubNode = newNode;
    newNode.lesserParent = self;
    
    [newNode addNewNode:self.rightSubNode];
}

- (void) substituteLeftWith:(DTNodeX *)newNode {
    self.rightSubNode.biggerParent = nil;
    self.rightSubNode = newNode;
    newNode.biggerParent = self;
    
    [newNode addNewNode:self.leftSubNode];
}

/*
   1                1
    \                \
     5                6
    / \       =>     / \
   3   6            5   8
  / \   \          /   / \
 2   4   8        3   7   9
        / \      / \       \
       7   9    2   4      10
            \
            10
 */
- (void) makeBetterBalance {
    if (self.leftCount == self.rightCount) return;
    DTNodeX *subNodeWhichIsBiggerThanMe;
    if (self.leftCount < self.rightCount) {
        subNodeWhichIsBiggerThanMe = self.rightSubNode;
        self.rightSubNode = nil;
        self.rightCount = 0;
    } else {
        subNodeWhichIsBiggerThanMe = self.leftSubNode;
        self.leftSubNode = nil;
        self.leftCount = 0;
    }
    if (self.lesserParent)
        [self.lesserParent substituteRightWith:subNodeWhichIsBiggerThanMe];
    else {
        if (self.biggerParent)
            [self.biggerParent substituteLeftWith:subNodeWhichIsBiggerThanMe];
    }
}

- (void) terminateAllConnections {
    self.leftCount = self.rightCount = 0;
    self.leftSubNode = self.rightSubNode = nil;
}

@end
