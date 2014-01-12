//
//  DTClusteringView.m
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/12/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "DTClusteringView.h"
#import "DTNodeX.h"
#import "DTCluster.h"

// hardcoded coordinate transform formula
#define TRANSX(x) (((x) + 1.2) * s.width)
#define TRANSY(y) (((y) + 1.3) * s.height)

@implementation DTClusteringView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (!self.allClusters) return;
    if (!self.allNodes) return;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize s = self.bounds.size;
    if (s.width > s.height) {
        s.width = s.height;
    } else {
        s.height = s.width;
    }
    s.width *= 1.0/2.4; // no objc calls and stupid code for faster drawing
    s.height *= 1.0/2.4;
    CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
    // drawing node cloud (clusterless nodes only)
    for (DTNodeX *node in self.allNodes) {
        if (node.cluster) continue;
        CGFloat x = TRANSX(node.value);
        CGFloat y = TRANSY(node.pair.value);
        CGContextAddRect(context, CGRectMake(x - 1, y - 1, 2, 2));
    }
    CGContextFillPath(context);
    if (!self.allClusters) return;
    CGContextSetRGBStrokeColor(context, 0.8, 0, 0.8, 1.0);
    CGContextSetLineWidth(context, 2.0);
    // drawing node cloud (clustered nodes only)
    [self.allClusters enumerateObjectsUsingBlock:^(DTCluster *cluster, NSUInteger idx, BOOL *stop) {
        CGFloat l = cluster.length * 0.5 * s.width;
        if (l < 1.0) l = .5;
        CGContextSetRGBFillColor(context, idx & 1, (idx & 2) >> 1, (idx & 4) >> 2, 0.5);
        for (DTNodeX *node in self.allNodes)
            if ([node.cluster isEqual:cluster]) {
                CGFloat x = TRANSX(node.value);
                CGFloat y = (node.pair.value + 1.3) * s.height;
                CGContextAddRect(context, CGRectMake(x - 1, y - 1, 2, 2));
            }
        CGContextFillPath(context);
        
        // clusters' pseudolines:
        //CGFloat x = TRANSX(cluster.centerX);
        //CGFloat y = TRANSY(cluster.centerY);
        //CGContextMoveToPoint(context, x + l*cos(cluster.angle), y + l*sin(cluster.angle));
        //CGContextAddLineToPoint(context, x - l*cos(cluster.angle), y - l*sin(cluster.angle));
        //CGContextStrokePath(context);
    }];
    
    // calculating overall cluser line. Not the best place for this code, actually
    NSMutableArray *line = [@[self.allClusters.firstObject] mutableCopy];
    NSMutableArray *rest = [self.allClusters mutableCopy];
    [rest removeObject:line.firstObject];
    while (rest.count > 0) {
        DTCluster *lineStart = line.firstObject;
        DTCluster *lineEnd = line.lastObject;
        DTCluster *newStart = [rest closestToCluster:lineStart];
        DTCluster *newEnd = [rest closestToCluster:lineEnd];
        float approximateDistance = ABS(newStart.centerX - lineStart.centerX) + ABS(newStart.centerY - lineStart.centerY);
        if (ABS(newEnd.centerX - lineEnd.centerX) + ABS(newEnd.centerY - lineEnd.centerY) < approximateDistance) {
            [line addObject:newEnd];
            [rest removeObject:newEnd];
        } else {
            [line insertObject:newStart atIndex:0];
            [rest removeObject:newStart];
        }
    }
    // drawing overall cluster line
    CGContextSetLineWidth(context, 20);
    CGContextSetRGBStrokeColor(context, 0.1, 0.1, 0.1, 0.2);
    [line enumerateObjectsUsingBlock:^(DTCluster *c, NSUInteger idx, BOOL *stop) {
        if (idx)
            CGContextAddLineToPoint(context, TRANSX(c.centerX), TRANSY(c.centerY));
        else
            CGContextMoveToPoint(context, TRANSX(c.centerX), TRANSY(c.centerY));
    }];
    CGContextStrokePath(context);
}

@end
