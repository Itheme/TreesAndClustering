//
//  DTViewController.m
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "DTViewController.h"
#import "DTAppDelegate.h"

@interface DTViewController ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSBlockOperation *xbalancingOperation;
@property (nonatomic, strong) NSBlockOperation *ybalancingOperation;

#pragma mark - Local Methods

/*!
 @abstract Balances graphs to normalize branch length dispersion
 @discussion Method starts x/ybalancingOperations and calls graph 'iterateBalancing' till operations are cancelled or graphs are fully normalized. Also operations invalidate graph representation views to show progress
 @param graphX - graph of x-nodes
 @param graphY - graph of y-nodes;
 @param context - model context
 */
- (void)balanceGraphX:(DTGraph *)graphX GraphY:(DTGraph *)graphY InContext:(NSManagedObjectContext *)context;

@end

@implementation DTViewController

- (void) updateRepresentationFor:(DTGraph *)graph {
    if ([self.graphRepresentationX.graph isEqual:graph])
        [self.graphRepresentationX performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
    else
        [self.graphRepresentationY performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void)balanceGraphX:(DTGraph *)graphX GraphY:(DTGraph *)graphY InContext:(NSManagedObjectContext *)context {
    self.xbalancingOperation = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.0];
        [graphX performSelectorOnMainThread:@selector(startBalancingInContext:) withObject:context waitUntilDone:YES];
        [self updateRepresentationFor:graphX];
        [NSThread sleepForTimeInterval:0.1];
        while (![self.xbalancingOperation isCancelled]) {
            [graphX performSelectorOnMainThread:@selector(iterateBalancing:) withObject:@5 waitUntilDone:YES];
            if (graphX.unbalancedNodes.count == 0) break;
            [self updateRepresentationFor:graphX];
            [NSThread sleepForTimeInterval:0.1];
        }
    }];
    self.ybalancingOperation = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.0];
        [graphY performSelectorOnMainThread:@selector(startBalancingInContext:) withObject:context waitUntilDone:YES];
        [self updateRepresentationFor:graphY];
        [NSThread sleepForTimeInterval:0.1];
        while (![self.ybalancingOperation isCancelled]) {
            [graphY performSelectorOnMainThread:@selector(iterateBalancing:) withObject:@5 waitUntilDone:YES];
            if (graphY.unbalancedNodes.count == 0) break;
            [self updateRepresentationFor:graphY];
            [NSThread sleepForTimeInterval:0.1];
        }
    }];
    __block DTViewController *this = self;
    [self.xbalancingOperation setCompletionBlock:^{
        [this updateRepresentationFor:graphX];
    }];
    [self.ybalancingOperation setCompletionBlock:^{
        [this updateRepresentationFor:graphY];
    }];
    self.queue = [[NSOperationQueue alloc] init];
    [self.queue addOperation:self.xbalancingOperation];
    [self.queue addOperation:self.ybalancingOperation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DTAppDelegate *appDelegate = (DTAppDelegate *)[UIApplication sharedApplication].delegate;
    self.graphRepresentationX.graph = appDelegate.graphX;
    self.graphRepresentationY.graph = appDelegate.graphY;
    [self balanceGraphX:appDelegate.graphX GraphY:appDelegate.graphY InContext:appDelegate.context];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)proceedToClustering:(id)sender {
    [self.xbalancingOperation cancel];
    [self.ybalancingOperation cancel];
    [self.xbalancingOperation waitUntilFinished];
    [self.ybalancingOperation waitUntilFinished];
}
@end
