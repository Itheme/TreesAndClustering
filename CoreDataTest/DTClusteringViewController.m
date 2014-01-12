//
//  DTClusteringViewController.m
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/12/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "DTClusteringViewController.h"
#import "DTAppDelegate.h"
#import "DTCluster.h"
#import "DTNodeX.h"

@interface DTClusteringViewController ()

@property (nonatomic, strong) NSArray *clusters;
@property (nonatomic, strong) NSOperation *clusteringOperation;
@property (nonatomic, strong) NSOperationQueue *queue;

#pragma mark - Local Methods

/*!
 @abstract Creates random linear clusters
 */
- (void) createClustersInContext:(NSManagedObjectContext *)context Model:(NSManagedObjectModel *)model;

/*!
 @abstract stimulateLeastClusters tries to inflate smallest clusters with their neighbours' nodes
 @discussion Method finds closest cluster and borrows closest node if it is not too far
 --@param least - smallest cluster passed to this method
 */
- (void) stimulateLeastClusters;

@end

@implementation DTClusteringViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) updateRepresentation {
    [self.clusteringRepresentation performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void)randomizeCluster:(DTCluster *)cluster {
    cluster.centerX = 1.5 - (3.0*rand()/RAND_MAX);
    cluster.centerY = 1.5 - (3.0*rand()/RAND_MAX);
    cluster.length = 0.0001;
}

- (void) createClustersInContext:(NSManagedObjectContext *)context Model:(NSManagedObjectModel *)model {
    NSEntityDescription *clusterDescription = model.entitiesByName[@"LinearCluster"];
    self.clusters = [[NSMutableArray alloc] init];
    for (int i = kCLUSTERCOUNT; i--; ) {
        DTCluster *cluster = [[DTCluster alloc] initWithEntity:clusterDescription insertIntoManagedObjectContext:context DistanceLimit:0.1];
        [context insertObject:cluster];
        [self randomizeCluster:cluster];
        [(NSMutableArray *)self.clusters addObject:cluster];
    }
    self.clusteringRepresentation.allClusters = self.clusters;
}

- (void) stimulateLeastClusters {
    // if we consider only one smallest cluster, we could end up with two smallest clusters borrowing nodes one from another. So we will need least0 & least1
    NSArray *sortedClusters = [self.clusters sortedArrayUsingComparator:^NSComparisonResult(DTCluster *c1, DTCluster *c2) {
        if (c2.nodes.count > c1.nodes.count)
            return NSOrderedAscending;
        if (c2.nodes.count == c1.nodes.count)
            return NSOrderedSame;
        return NSOrderedDescending;
    }];
    DTCluster *closest0 = nil;
    DTCluster *closest1 = nil;
    float distance = INFINITY;
    DTCluster *least0 = ((DTCluster *)sortedClusters[0]);
    DTCluster *least1 = ((DTCluster *)sortedClusters[1]);
    for (DTCluster *c in self.clusters) {
        if ([c isEqual:least0] || [c isEqual:least1])
            continue;
        float d = sqrtf(powf(c.centerX - least0.centerX, 2) + powf(c.centerY - least0.centerY, 2));
        if (d < distance) {
            closest0 = c;
            distance = d;
        }
    }
    distance = INFINITY;
    for (DTCluster *c in self.clusters) {
        if ([c isEqual:least0] || [c isEqual:least1] || [c isEqual:closest0])
            continue;
        float d = sqrtf(powf(c.centerX - least1.centerX, 2) + powf(c.centerY - least1.centerY, 2));
        if (d < distance) {
            closest1 = c;
            distance = d;
        }
    }
    DTAppDelegate *appDelegate = (DTAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.context;
    [least0 borrowNodeFrom:closest0 InContext:context];
    [least1 borrowNodeFrom:closest1 InContext:context];
}

- (void)killLeastClusters {
    NSArray *sortedClusters = [self.clusters sortedArrayUsingComparator:^NSComparisonResult(DTCluster *c1, DTCluster *c2) {
        if (c2.nodes.count > c1.nodes.count)
            return NSOrderedAscending;
        if (c2.nodes.count == c1.nodes.count)
            return NSOrderedSame;
        return NSOrderedDescending;
    }];
    DTCluster *least = sortedClusters[2]; // zero & one could be newborn objects
    DTCluster *most = sortedClusters.lastObject;
    if (least.nodes.count < most.nodes.count * 0.5) {
        while (least.nodes.count > 0) {
            DTNodeX *node = least.nodes.anyObject;
            node.cluster = nil;
        }
        [self randomizeCluster:least];
    }
}

- (void)viewDidLoad
{
    NSError *error = nil;

    [super viewDidLoad];
    DTAppDelegate *appDelegate = (DTAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.context;
    [self createClustersInContext:context Model:appDelegate.model];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"NodeX"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES]];
        
    self.clusteringRepresentation.allNodes = [context executeFetchRequest:fetchRequest error:&error];

    if (error)
        @throw [NSException exceptionWithName:@"Error in executeFetchRequest" reason:@"Nodes are inaccessible" userInfo:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doClustering:(id)sender {
    if (self.clusteringOperation) return;
    DTAppDelegate *appDelegate = (DTAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.context;
    self.clusteringOperation = [NSBlockOperation blockOperationWithBlock:^{
        BOOL everybodyDone;
        int iterationNo = 0;
        do {
            everybodyDone = YES;
            [NSThread sleepForTimeInterval:0.1];
            [self updateRepresentation];
            
            for (DTCluster *cluster in self.clusters) {
                [cluster performSelectorOnMainThread:@selector(iterateSelfOrganizationInContext:) withObject:context waitUntilDone:YES];
            }
            [self performSelectorOnMainThread:@selector(stimulateLeastClusters) withObject:nil waitUntilDone:YES];
            if ((iterationNo % 30) == 0)
                [self performSelectorOnMainThread:@selector(killLeastClusters) withObject:nil waitUntilDone:YES];
            everybodyDone = YES;
            iterationNo++;
        } while (everybodyDone || [self.clusteringOperation isCancelled]);
        [self updateRepresentation];

    }];
    __block DTClusteringViewController *this = self;
    [self.clusteringOperation setCompletionBlock:^{
        [this updateRepresentation];
    }];
    self.queue = [[NSOperationQueue alloc] init];
    [self.queue addOperation:self.clusteringOperation];
//    [self.clusteringOperation start];
//    [this updateRepresentation];
    
}
@end
