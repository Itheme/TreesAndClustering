//
//  DTAppDelegate.m
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "DTAppDelegate.h"
#import "DTNodeX.h"

@interface DTAppDelegate ()

@property (nonatomic, strong) DTGraph *graphX;
@property (nonatomic, strong) DTGraph *graphY;
@property (nonatomic, strong) NSManagedObjectModel *model;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *context;

#pragma mark - Local Methods

/*!
 @abstract Creates kCLOUDSIZE of NodeXs and kCLOUDSIZE of NodeYs connected in pairs by 'pair' property and assigns them to graphX and graphY correspondingly
 */
- (void)fillNodes;

/*!
 @abstract Creates model, context and initialized graphX and graphY
 @discussion Assuming Model is called 'Model' and located in the main bundle
 */
- (void)createModel;

@end

@implementation DTAppDelegate

- (void) createModel {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    self.model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [self.context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
    NSEntityDescription *graphEntityDescriptionX = [self.model entitiesByName][@"GraphX"];
    NSEntityDescription *graphEntityDescriptionY = [self.model entitiesByName][@"GraphY"];
	
    self.graphX = [[DTGraph alloc] initWithEntity:graphEntityDescriptionX insertIntoManagedObjectContext:self.context];
    [self.context insertObject:self.graphX];
    self.graphY = [[DTGraph alloc] initWithEntity:graphEntityDescriptionY insertIntoManagedObjectContext:self.context];
    [self.context insertObject:self.graphY];
}

- (DTNodeX *)addNewNode:(float) nodeValue Graph:(DTGraph *) graph Description:(NSEntityDescription *)nodeDescription {
    DTNodeX *x = [[DTNodeX alloc] initWithEntity:nodeDescription insertIntoManagedObjectContext:self.context];
    x.value = nodeValue;
    if (graph.rootNode) {
        [graph.rootNode addNewNode:x];
    } else {
        graph.rootNode = x;
    }
    [self.context insertObject:x];
    return x;
}

- (void)fillNodes {
    NSEntityDescription *nodeDescriptionX = [self.model entitiesByName][self.graphX.preferedNodeEntityName];
    NSEntityDescription *nodeDescriptionY = [self.model entitiesByName][self.graphY.preferedNodeEntityName];
    for (int i = kCLOUDSIZE; i--; ) {
        double radians = M_PI*3.0*rand()/RAND_MAX;
        DTNodeX *x = [self addNewNode:cos(radians)*radians/9.5+0.15*rand()/RAND_MAX-0.075 Graph:self.graphX Description:nodeDescriptionX];
        x.pair = [self addNewNode:sin(radians)*radians/9.5+0.15*rand()/RAND_MAX-0.075 Graph:self.graphY Description:nodeDescriptionY];
        x.pair.pair = x;
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self createModel];
    [self fillNodes];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
