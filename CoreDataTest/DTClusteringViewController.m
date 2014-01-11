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

@interface DTClusteringViewController ()

@property (nonatomic, strong) NSArray *clusters;
@property (nonatomic, strong) NSOperation *clusteringOperation;
@property (nonatomic, strong) NSOperationQueue *queue;

#pragma mark - Local Methods

/*!
 @abstract Creates random linear clusters
 */
- (void) createClustersInContext:(NSManagedObjectContext *)context Model:(NSManagedObjectModel *)model;

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

- (void) createClustersInContext:(NSManagedObjectContext *)context Model:(NSManagedObjectModel *)model {
    NSEntityDescription *clusterDescription = model.entitiesByName[@"LinearCluster"];
    self.clusters = [[NSMutableArray alloc] init];
    for (int i = kCLUSTERCOUNT; i--; ) {
        DTCluster *cluster = [[DTCluster alloc] initWithEntity:clusterDescription insertIntoManagedObjectContext:context];
        [context insertObject:cluster];
        cluster.centerX = 1.5 - 3.0*rand()/RAND_MAX;
        cluster.centerY = 1.5 - 3.0*rand()/RAND_MAX;
        cluster.length = 1.0;
        [(NSMutableArray *)self.clusters addObject:cluster];
    }
    self.clusteringRepresentation.allClusters = self.clusters;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    DTAppDelegate *appDelegate = (DTAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.context;
    [self createClustersInContext:context Model:appDelegate.model];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"NodeX"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES]];
    NSError *error = nil;
    
    self.clusteringRepresentation.allNodes = [context executeFetchRequest:fetchRequest error:&error];
    if (error)
        return;

    self.clusteringOperation = [NSBlockOperation blockOperationWithBlock:^{
        BOOL everybodyDone;
        do {
            everybodyDone = YES;
            [NSThread sleepForTimeInterval:0.1];
            [self updateRepresentation];
            for (DTCluster *cluster in self.clusters) {
                if (![cluster iterateSelfOrganizationInContext:context DistanceLinit:0.1])
                    everybodyDone = NO;
            }
        } while (!everybodyDone && ![self.clusteringOperation isCancelled]);
    }];
    __block DTClusteringViewController *this = self;
    [self.clusteringOperation setCompletionBlock:^{
        [this updateRepresentation];
    }];
    self.queue = [[NSOperationQueue alloc] init];
    [self.queue addOperation:self.clusteringOperation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
