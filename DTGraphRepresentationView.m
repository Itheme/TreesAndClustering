//
//  DTGraphRepresentationView.m
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "DTGraphRepresentationView.h"
#import "DTNodeX.h"

@implementation DTGraphRepresentationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawNode:(DTNodeX *)node InContext:(CGContextRef) context Since:(CGPoint) startPoint LineLength:(CGSize)ls{
    if (ls.width < 0.1) return;
    for (BranchSide s = bLeft; s <= bRight; s++) {
        DTNodeX *subNode = [node getNodeBySide:s];
        if (subNode) {
            CGPoint p = CGPointMake(startPoint.x, startPoint.y + ls.height);
            if (s == bLeft)
                p.x -= ls.width;
            else
                p.x += ls.width;
            CGContextMoveToPoint(context, startPoint.x, startPoint.y);
            CGContextAddLineToPoint(context, p.x, p.y);
            [self drawNode:subNode InContext:context Since:p LineLength:CGSizeMake(ls.width - .8, ls.height)];
        }
    }
}

- (void)drawRect:(CGRect)rect
{
    if (self.graph && self.graph.rootNode) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGSize s = self.bounds.size;
        //CGPoint *lines = malloc(MAX(self.graph.rootNode.leftCount, self.graph.rootNode.rightCount)*sizeof(CGPoint));
        [self drawNode:self.graph.rootNode InContext:context Since:CGPointMake(s.width *.5, 40) LineLength:CGSizeMake(20, 10)];
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        CGContextStrokePath(context);
    }
}

@end
