//
//  DTAppDelegate.h
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTGraph.h"

@interface DTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, readonly, strong) DTGraph *graphX;
@property (nonatomic, readonly, strong) DTGraph *graphY;
@property (nonatomic, readonly, strong) NSManagedObjectModel *model;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly, strong) NSManagedObjectContext *context;


@end
