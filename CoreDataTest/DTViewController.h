//
//  DTViewController.h
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTGraphRepresentationView.h"
#import "DTGraph.h"
#import "DTNodeX.h"

@interface DTViewController : UIViewController

@property (weak, nonatomic) IBOutlet DTGraphRepresentationView *graphRepresentationX; // graphX representation
@property (weak, nonatomic) IBOutlet DTGraphRepresentationView *graphRepresentationY; // graphY representation

- (IBAction)proceedToClustering:(id)sender;

@end
