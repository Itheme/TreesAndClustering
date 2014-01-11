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
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGSize s = self.bounds.size;
    if (s.width > s.height) {
        s.width = s.height;
    } else {
        s.height = s.width;
    }
    s.width *= 1.0/2.4; // no objc calls and stupid code for faster drawing
    s.height *= 1.0/2.4;
    if (self.allNodes) {
        CGContextSetRGBFillColor(context, 0, 0, 0, 1.0);
        for (DTNodeX *node in self.allNodes) {
            CGFloat x = (node.value + 1.2) * s.width;
            CGFloat y = (node.pair.value + 1.3) * s.height;
            CGContextAddRect(context, CGRectMake(x - 1, y - 1, 2, 2));
        }
        CGContextFillPath(context);
    }
    if (self.allClusters) {
        CGContextSetRGBStrokeColor(context, 0.8, 0, 0.8, 0.5);
        for (DTCluster *cluster in self.allClusters) {
            CGFloat x = (cluster.centerX + 1.2) * s.width;
            CGFloat y = (cluster.centerY + 1.3) * s.height;
            CGContextMoveToPoint(context, x + cluster.length*0.5*cos(cluster.angle), y + cluster.length*0.5*sin(cluster.angle));
            CGContextAddLineToPoint(context, x - cluster.length*0.5*cos(cluster.angle), y - cluster.length*0.5*sin(cluster.angle));
        }
        CGContextStrokePath(context);
    }
    
}

@end
