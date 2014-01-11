//
//  DTViewController.m
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "DTViewController.h"

@interface DTViewController ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSBlockOperation *xbalancingOperation;
@property (nonatomic, strong) NSBlockOperation *ybalancingOperation;

@end

@implementation DTViewController

- (void)addNewNode:(float) nodeValue Graph:(DTGraph *) graph Description:(NSEntityDescription *)nodeDescription {
    DTNodeX *x = [[DTNodeX alloc] initWithEntity:nodeDescription insertIntoManagedObjectContext:self.context];
    x.value = nodeValue;
    if (graph.rootNode) {
        [graph.rootNode addNewNode:x];
    } else {
        graph.rootNode = x;
    }
    [self.context insertObject:x];
}

- (void)fillNodes {
    NSEntityDescription *nodeDescriptionX = [self.model entitiesByName][@"NodeX"];
    NSEntityDescription *nodeDescriptionY = [self.model entitiesByName][@"NodeY"];
    for (int i = 1000; i--; ) {
        double radians = M_PI*2.0*rand()/RAND_MAX;
        [self addNewNode:cos(radians) Graph:self.graphX Description:nodeDescriptionX];
        [self addNewNode:sin(radians) Graph:self.graphY Description:nodeDescriptionY];
    }
}

/*
 0                         0
  \                         \
   2                    =>   3
  / \   empty left      =>  / \
 1  >3< branch here        2   5
      \                   /   / \
       5                 1   4   6
      / \
     4   6
 */
//
//- (BOOL)useEmptyBranches:(BOOL) oneStepOnly {
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"NodeX"];
//    fetchRequest.predicate = [NSPredicate predicateWithBlock:^BOOL(DTNodeX *evaluatedObject, NSDictionary *bindings) {
//        if (evaluatedObject.leftSubNode)
//            return NO;
//        if (evaluatedObject.rightSubNode) {
//            return NO;//((evaluatedObject.rightSubNode.rightSubNode) && (evaluatedObject.rightSubNode.leftSubNode == nil));
//        }
//        return YES;
//    }];
//    if (oneStepOnly)
//        fetchRequest.fetchLimit = 1;
//    
//    NSError *error = nil;
//        
//    NSArray *unbalanced = [self.context executeFetchRequest:fetchRequest error:&error];
//    if (error == nil)
//        for (DTNodeX *node in unbalanced) {
//            DTNodeX *exR = node.rightSubNode;
//            node.rightSubNode = node.rightSubNode.rightSubNode;
//            node.rightCount -= 1;
//            node.leftCount += 1;
//            node.rightSubNode.leftSubNode = exR;
//            exR.rightCount = 0;
//            exR.leftCount = 0;
//            if (oneStepOnly)
//                return YES;
//        }
//        
//    fetchRequest.predicate = [NSPredicate predicateWithBlock:^BOOL(DTNodeX *evaluatedObject, NSDictionary *bindings) {
//        if (evaluatedObject.rightSubNode)
//            return NO;
//        if (evaluatedObject.leftSubNode)
//            return ((evaluatedObject.leftSubNode.leftSubNode) && (evaluatedObject.leftSubNode.rightSubNode == nil));
//        return NO;
//    }];
//        
//    unbalanced = [self.context executeFetchRequest:fetchRequest error:&error];
//    if (error == nil)
//        for (DTNodeX *node in unbalanced) {
//            DTNodeX *exL = node.leftSubNode;
//            node.leftSubNode = node.leftSubNode.leftSubNode;
//            node.rightCount += 1;
//            node.leftCount -= 1;
//            node.leftSubNode.rightSubNode = exL;
//            exL.rightCount = 0;
//            exL.leftCount = 0;
//            if (oneStepOnly)
//                return YES;
//        }
//    return NO;
//}
//
//- (BOOL)balance {
//    NSFetchRequest *mostUnbalanced = [[NSFetchRequest alloc] initWithEntityName:@"NodeX"];
//    mostUnbalanced.predicate = [NSPredicate predicateWithFormat:@"balance > 3"];
//    mostUnbalanced.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"balance" ascending:NO]];
//    mostUnbalanced.fetchLimit = 100;
//    while (true) {
//        NSError *error = nil;
//    
//        NSArray *unbalanced = [self.context executeFetchRequest:mostUnbalanced error:&error];
//        if (unbalanced.count <= 1) break;
//        if (error) break;
//        for (DTNodeX *node in unbalanced) {
//            if ((node.biggerParent == nil) && (node.lesserParent == nil)) // root node
//                continue;
//                #warning balance root too someday
//            [node makeBetterBalance];
//            return YES;
//        }
//    }
//    return NO;
//}

- (void) updateGraphXRepresentation {
    [self.graphRepresentationX performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void) updateGraphYRepresentation {
    [self.graphRepresentationY performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    self.model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [self.context setPersistentStoreCoordinator:self.persistentStoreCoordinator];

    NSEntityDescription *graphEntityDescriptionX = [self.model entitiesByName][@"GraphX"];
    NSEntityDescription *graphEntityDescriptionY = [self.model entitiesByName][@"GraphY"];
	
    self.graphX = [[DTGraph alloc] initWithEntity:graphEntityDescriptionX insertIntoManagedObjectContext:self.context];
    [self.context insertObject:self.graphX];
    self.graphRepresentationX.graph = self.graphX;
    self.graphY = [[DTGraph alloc] initWithEntity:graphEntityDescriptionY insertIntoManagedObjectContext:self.context];
    [self.context insertObject:self.graphY];
    self.graphRepresentationY.graph = self.graphY;
    [self fillNodes];
    
    
    self.xbalancingOperation = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:5.0];
        [self.graphX startBalancingInContext:self.context NodeEntityName:@"NodeX"];
        [self updateGraphXRepresentation];
        [NSThread sleepForTimeInterval:0.1];
        while ([self.graphX iterateBalancing:5] && ![self.xbalancingOperation isCancelled]) {
            [self updateGraphXRepresentation];
            [NSThread sleepForTimeInterval:0.1];
        }
    }];
    self.ybalancingOperation = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:5.0];
        [self.graphY startBalancingInContext:self.context NodeEntityName:@"NodeY"];
        [self updateGraphYRepresentation];
        [NSThread sleepForTimeInterval:0.1];
        while ([self.graphY iterateBalancing:5] && ![self.ybalancingOperation isCancelled]) {
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
