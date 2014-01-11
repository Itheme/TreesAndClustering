//
//  DTNodeX.h
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DTNodeX;

@interface DTNodeX : NSManagedObject

@property (nonatomic) int32_t left;
@property (nonatomic) int32_t right;
@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) DTNodeX *subNode0;
@property (nonatomic, retain) DTNodeX *subNode1;

@end
