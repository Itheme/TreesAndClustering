//
//  DTCluster.m
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/12/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "DTCluster.h"
#import "DTNodeX.h"
#import <math.h>

@implementation DTCluster

@dynamic centerX;
@dynamic centerY;
@dynamic angle;
@dynamic length;
@dynamic nodes;

- (DTNodeX *)ClosestTo:(CGPoint) p NodeInArray:(NSArray *)unbound DistanceLimit:(float)distanceLimit {
    DTNodeX *closeOne = nil;
    float closeD = INFINITY;
    for (DTNodeX *node in unbound) {
        float d = sqrt(pow(p.x - node.value, 2) + pow(p.y - node.pair.value, 2));
        if (d < closeD) {
            closeOne = node;
            closeD = d;
        }
    }
    if (distanceLimit < closeD)
        return nil;
    return closeOne;
}

- (BOOL)iterateSelfOrganizationInContext:(NSManagedObjectContext *)context DistanceLimit:(float)distanceLimit {
    BOOL firstIteration = self.nodes.count == 0;
    if (firstIteration)
        distanceLimit = INFINITY;
    NSFetchRequest *unboundNodes = [[NSFetchRequest alloc] initWithEntityName:@"NodeX"];
    __block float x = self.centerX;
    __block float y = self.centerY;
    unboundNodes.predicate = [NSPredicate predicateWithBlock:^BOOL(DTNodeX *evaluatedObject, NSDictionary *bindings) {
        if (evaluatedObject.cluster) return NO;
        float veryApproximateDistance = ABS(x - evaluatedObject.value) + ABS(y - evaluatedObject.pair.value);
        if (veryApproximateDistance > distanceLimit) return NO;
        return YES;
    }];
    //unboundNodes.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastEffectiveDistance" ascending:YES]];
    NSError *error = nil;
    
    NSArray *unbound = [context executeFetchRequest:unboundNodes error:&error];
    if (error || (unbound.count == 0)) {
        return NO;
    }
    
    DTNodeX *node = [self ClosestTo:CGPointMake(x, y) NodeInArray:unbound DistanceLimit:distanceLimit];
    if (node == nil) return NO;
    if (firstIteration) {
        self.centerX = node.value;
        self.centerY = node.pair.value;
    } else { // calculating center, angle and length
        CGPoint mean = CGPointZero;
        for (DTNodeX *nodeX in self.nodes) {
            mean.x += nodeX.value;
            mean.y += nodeX.pair.value;
        }
        mean.x/=self.nodes.count;
        mean.y/=self.nodes.count;
        float maxHalfLength = 0;
        float meanDXDY = 0;
        for (DTNodeX *nodeX in self.nodes) {
            float dx = nodeX.value - mean.x;
            float dy = nodeX.pair.value - mean.y;
            meanDXDY += dx/dy;
            float l = pow(dx, 2) + pow(dy, 2);
            if (l > maxHalfLength) maxHalfLength = l;
        }
        maxHalfLength = sqrt(maxHalfLength);
        if (isfinite(meanDXDY)) {
            self.angle = atan(meanDXDY / self.nodes.count);
        } else
            self.angle = M_PI_2;
        self.centerX = mean.x;
        self.centerY = mean.y;
        self.length = maxHalfLength * 2;
    }
    node.cluster = self;
    return YES;
}

@end
