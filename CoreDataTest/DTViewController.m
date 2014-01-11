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

- (void) updateGraphXRepresentation {
    [self.graphRepresentationX performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void) updateGraphYRepresentation {
    [self.graphRepresentationY performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void)balanceGraphX:(DTGraph *)graphX GraphY:(DTGraph *)graphY InContext:(NSManagedObjectContext *)context {
    self.xbalancingOperation = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.0];
        @synchronized (graphX) {
            [graphX startBalancingInContext:context NodeEntityName:@"NodeX"];
        }
        [self updateGraphXRepresentation];
        [NSThread sleepForTimeInterval:0.1];
        while (![self.xbalancingOperation isCancelled]) {
            @synchronized (graphX) {
                if (![graphX iterateBalancing:5]) break;
            }
            [self updateGraphXRepresentation];
            [NSThread sleepForTimeInterval:0.1];
        }
    }];
    self.ybalancingOperation = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.0];
        @synchronized (graphY) {
            [graphY startBalancingInContext:context NodeEntityName:@"NodeY"];
        }
        [self updateGraphYRepresentation];
        [NSThread sleepForTimeInterval:0.1];
        while (![self.ybalancingOperation isCancelled]) {
            @synchronized (graphY) {
                if (![graphY iterateBalancing:5]) break;
            }
            [self updateGraphYRepresentation];
            [NSThread sleepForTimeInterval:0.1];
        }
    }];
    __block DTViewController *this = self;
    [self.xbalancingOperation setCompletionBlock:^{
        [this updateGraphXRepresentation];
    }];
    [self.ybalancingOperation setCompletionBlock:^{
        [this updateGraphYRepresentation];
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
