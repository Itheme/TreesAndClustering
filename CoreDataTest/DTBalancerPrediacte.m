//
//  DTBalancerPrediacte.m
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "DTBalancerPrediacte.h"
#import "DTNodeX.h"

@implementation DTBalancerPrediacte

- (id) initForLeft {
    self = [super init];
    if (self) {
        lefty = YES;
    }
    return self;
}

- (id) initForRight {
    return (self = [super init]);
}

// checking node for having two left and no right subnodes, or two right and no left subnodes

- (BOOL)evaluateWithObject:(id)object { // evaluate a predicate against a single object
    DTNodeX *x = object;
    if (lefty) {
        if (x.rightSubNode)
            return NO;
        if (x.leftSubNode) {
            return ((x.leftSubNode.leftSubNode) && (x.leftSubNode.rightSubNode == nil));
        }
    } else {
        if (x.leftSubNode)
            return NO;
        if (x.rightSubNode) {
            return ((x.rightSubNode.rightSubNode) && (x.rightSubNode.leftSubNode == nil));
        }
    }
    return NO;
}

- (BOOL)evaluateWithObject:(id)object substitutionVariables:(NSDictionary *)bindings {
    @throw [NSException exceptionWithName:@"Not supported" reason:@"evaluateWithObject:substitutionVariables: not supported yet" userInfo:nil];
}

@end
