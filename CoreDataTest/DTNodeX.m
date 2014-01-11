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

@dynamic leftCount;
@dynamic rightCount;
@dynamic value;
@dynamic data;
@dynamic name;
@dynamic biggerParent, lesserParent;
@dynamic leftSubNode, rightSubNode;

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

@end
