//
//  DTClusteringViewController.h
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/12/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTClusteringView.h"

@interface DTClusteringViewController : UIViewController

@property (weak, nonatomic) IBOutlet DTClusteringView *clusteringRepresentation;

- (IBAction)doClustering:(id)sender;

@end
