//
//  DTViewController.m
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "DTViewController.h"
#import "DTBalancerPrediacte.h"

@interface DTViewController ()

@end

@implementation DTViewController

- (void)fillNodes {
    NSEntityDescription *nodeDescription = [self.model entitiesByName][@"NodeX"];//[[NSEntityDescription alloc] init];
//    [nodeDescription setName:@"NodeX"];
//    [nodeDescription setManagedObjectClassName:@"DTNodeX"];
//    NSAttributeDescription *valueDescription = [[NSAttributeDescription alloc] init];
//    valueDescription.name = @"value";
//    valueDescription.attributeType = NSFloatAttributeType;
//    [nodeDescription setProperties:@[valueDescription]];
    DTNodeX *x;
    for (int i = 1000; i--; [self.context insertObject:x]) {
        x = [[DTNodeX alloc] initWithEntity:nodeDescription insertIntoManagedObjectContext:self.context];
        x.value = cos(M_PI*2.0*rand()/RAND_MAX);
        if (self.graph.rootNode) {
            [self.graph.rootNode addNewNode:x];
        } else {
            self.graph.rootNode = x;
        }
    }
}

- (void)balance {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"NodeX"];
    fetchRequest.predicate = [NSPredicate predicateWithBlock:^BOOL(DTNodeX *evaluatedObject, NSDictionary *bindings) {
        if (evaluatedObject.leftSubNode)
            return NO;
        if (evaluatedObject.rightSubNode) {
            return ((evaluatedObject.rightSubNode.rightSubNode) && (evaluatedObject.rightSubNode.leftSubNode == nil));
        }
        return NO;
    }];
    //fetchRequest.fetchLimit = 1;
    //fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"personId" ascending:NO]];
    
    NSError *error = nil;
    
    NSArray *unbalanced = [self.context executeFetchRequest:fetchRequest error:&error];
    if (error == nil)
        for (DTNodeX *node in unbalanced) {
            DTNodeX *exR = node.rightSubNode;
            node.rightSubNode = node.rightSubNode.rightSubNode;
            node.rightCount -= 1;
            node.leftCount += 1;
            node.rightSubNode.leftSubNode = exR;
            exR.rightCount = 0;
            exR.leftCount = 0;
        }
    
    fetchRequest.predicate = [NSPredicate predicateWithBlock:^BOOL(DTNodeX *evaluatedObject, NSDictionary *bindings) {
        if (evaluatedObject.rightSubNode)
            return NO;
        if (evaluatedObject.leftSubNode)
            return ((evaluatedObject.leftSubNode.leftSubNode) && (evaluatedObject.leftSubNode.rightSubNode == nil));
        return NO;
    }];
    
    unbalanced = [self.context executeFetchRequest:fetchRequest error:&error];
    if (error == nil)
        for (DTNodeX *node in unbalanced) {
            DTNodeX *exL = node.leftSubNode;
            node.leftSubNode = node.leftSubNode.leftSubNode;
            node.rightCount += 1;
            node.leftCount -= 1;
            node.leftSubNode.rightSubNode = exL;
            exL.rightCount = 0;
            exL.leftCount = 0;
        }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    self.model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [self.context setPersistentStoreCoordinator:self.persistentStoreCoordinator];

    NSEntityDescription *entityDescription = [self.model entitiesByName][@"Graph"];//[[NSEntityDescription alloc] init];
    //[entityDescription setName:@"Graph"];
    //[entityDescription setManagedObjectClassName:@"DTGraph"];
    
    //NSMutableArray *appointmentSearchResponseProperties = [NSMutableArray array];
    //NSAttributeDescription *messageType = [[NSAttributeDescription alloc] init];
    //[messageType setName:@"messages"];
    //[messageType setAttributeType:NSTransformableAttributeType];
    //[appointmentSearchResponseProperties addObject:messageType];
    
    //[entityDescription setProperties:appointmentSearchResponseProperties];
	self.graph = [[DTGraph alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:self.context];
    [self.context insertObject:self.graph];
    [self fillNodes];
    [self balance];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
