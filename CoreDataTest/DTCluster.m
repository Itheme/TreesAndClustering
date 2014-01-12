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

@interface DTCluster () {
    float defaultDistanceLimit;
}

@end

@implementation DTCluster

@dynamic centerX;
@dynamic centerY;
@dynamic angle;
@dynamic length;
@dynamic nodes;

- (id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context DistanceLimit:(float)distanceLimit {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        defaultDistanceLimit = distanceLimit;
    }
    return self;
}

- (DTNodeX *)ClosestTo:(CGPoint) p NodeInArray:(NSArray *)unbound DistanceLimit:(float) distanceLimit {
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

- (BOOL)iterateSelfOrganizationInContext:(NSManagedObjectContext *)context WithPredicateBlock:(BOOL (^)(id evaluatedObject, NSDictionary *bindings))block {
    BOOL firstIteration = self.nodes.count == 0;
    float distanceLimit;
    if (firstIteration)
        distanceLimit = INFINITY;
    else
        distanceLimit = defaultDistanceLimit;
    NSFetchRequest *unboundNodes = [[NSFetchRequest alloc] initWithEntityName:@"NodeX"];
    unboundNodes.predicate = [NSPredicate predicateWithBlock:block];
    //unboundNodes.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastEffectiveDistance" ascending:YES]];
    NSError *error = nil;
    
    NSArray *unbound = [context executeFetchRequest:unboundNodes error:&error];
    if (error || (unbound.count == 0)) {
        return NO;
    }
    
    float x = self.centerX;
    float y = self.centerY;
    float kx = self.length * 0.5 * cos(self.angle);
    float ky = self.length * 0.5 * sin(self.angle);
    DTNodeX *node = [self ClosestTo:CGPointMake(x + kx, y + ky) NodeInArray:unbound DistanceLimit:distanceLimit];
    if (node == nil) {
        node = [self ClosestTo:CGPointMake(x, y) NodeInArray:unbound DistanceLimit:distanceLimit];
        if (node == nil) {
            node = [self ClosestTo:CGPointMake(x - kx, y - ky) NodeInArray:unbound DistanceLimit:distanceLimit];
            if (node == nil) return NO;
        }
    }
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
        float meanDYDX = 0;
        for (DTNodeX *nodeX in self.nodes) {
            float dx = nodeX.value - mean.x;
            float dy = nodeX.pair.value - mean.y;
            meanDYDX += dy/dx;
            float l = pow(dx, 2) + pow(dy, 2);
            if (l > maxHalfLength) maxHalfLength = l;
        }
        maxHalfLength = sqrt(maxHalfLength);
        if (isfinite(meanDYDX)) {
            self.angle = atan(meanDYDX / self.nodes.count);
        } else
            self.angle = M_PI_2;
        self.centerX = mean.x;
        self.centerY = mean.y;
        self.length = maxHalfLength * 2;
    }
    node.cluster = self;
    return YES;
}

- (BOOL)iterateSelfOrganizationInContext:(NSManagedObjectContext *)context {
    BOOL firstIteration = self.nodes.count == 0;
    float distanceLimit;
    if (firstIteration)
        distanceLimit = INFINITY;
    else
        distanceLimit = defaultDistanceLimit;//MAX(defaultDistanceLimit, self.length);
    float generousLimit = MAX(distanceLimit, self.length * 3);
    __block float x = self.centerX;
    __block float y = self.centerY;
    return [self iterateSelfOrganizationInContext:context WithPredicateBlock:^BOOL(DTNodeX *evaluatedObject, NSDictionary *bindings) {
        if (evaluatedObject.cluster) return NO;
        float veryApproximateDistance = ABS(x - evaluatedObject.value) + ABS(y - evaluatedObject.pair.value);
        if (veryApproximateDistance > generousLimit) return NO;
        return YES;
    }];
}

- (void)borrowNodeFrom:(DTCluster *)cluster InContext:(NSManagedObjectContext *)context {
    __block float x = self.centerX;
    __block float y = self.centerY;
    float generousLimit = self.length * 3;
    [self iterateSelfOrganizationInContext:context WithPredicateBlock:^BOOL(DTNodeX *evaluatedObject, NSDictionary *bindings) {
        if (evaluatedObject.cluster != cluster) return NO;
        float veryApproximateDistance = ABS(x - evaluatedObject.value) + ABS(y - evaluatedObject.pair.value);
        if (veryApproximateDistance > generousLimit) return NO;
        return YES;

    }];
}

@end

@implementation NSArray (DTClusterArray)

- (DTCluster *) closestToCluster:(DTCluster *)cluster {
    float distance = INFINITY;
    DTCluster *closest = nil;
    for (DTCluster *c in self) {
        float d = sqrtf(powf(cluster.centerX - c.centerX, 2.0) + powf(cluster.centerY - c.centerY, 2.0));
        if (d < distance) {
            closest = c;
            distance = d;
        }
    }
    return closest;
}

@end
