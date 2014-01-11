//
//  DTViewController.m
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "DTViewController.h"

@interface DTViewController ()

@end

@implementation DTViewController

- (void)fillNodes {
    for (int i = 1000; i--; ) {
        DTNodeX *x = [[DTNodeX alloc] init];
//        x.
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSEntityDescription *entityDescription = [[NSEntityDescription alloc] init];
    //[entityDescription setName:@"TheGraph"];
    //[entityDescription setManagedObjectClassName:@"DTGraph"];
    
    //NSMutableArray *appointmentSearchResponseProperties = [NSMutableArray array];
    //NSAttributeDescription *messageType = [[NSAttributeDescription alloc] init];
    //[messageType setName:@"messages"];
    //[messageType setAttributeType:NSTransformableAttributeType];
    //[appointmentSearchResponseProperties addObject:messageType];
    
    //[entityDescription setProperties:appointmentSearchResponseProperties];
	self.graph = [[DTGraph alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
