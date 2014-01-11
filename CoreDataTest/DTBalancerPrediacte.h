//
//  DTBalancerPrediacte.h
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTBalancerPrediacte : NSPredicate {
    BOOL lefty;
}

- (id) initForLeft;
- (id) initForRight;


@end
