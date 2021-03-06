//
//  DTGraph.m
//  CoreDataTest
//
//  Created by Danila Parhomenko on 1/11/14.
//  Copyright (c) 2014 Danila Parhomenko. All rights reserved.
//

#import "DTGraph.h"
#import "DTNodeX.h"

@interface DTGraph () {
    int medianIndex;
}

// allNodes contains all nodes associated with this graph. Array is initialized by startBalancingInContext: method
@property (nonatomic, strong) NSArray *allNodes;

// unbalancedNodes array contains dictionaries for all nodes that should be balanced by iterateBalancing: method. Each node dictionary consists of "node": DTNode entity, "leftRange": NSIndexSet of nodes that have smaller value than "node", "rightRange": NSIndexSet for bigger nodes.
@property (nonatomic, strong) NSMutableArray *unbalancedNodes;

// preferedNodeEntityName is "NodeX" for "GraphX" and "NodeY" for "GraphY"
@property (nonatomic, strong) NSString *preferedNodeEntityName;

@end

@implementation DTGraph

@dynamic rootNode;

@synthesize allNodes = _allNodes;
@synthesize unbalancedNodes = _unbalancedNodes;
@synthesize preferedNodeEntityName;

static NSArray *rangeNames;

- (NSDictionary *)unbalancedNodeRecordAtIndex:(int) index WithinRange:(NSRange) range {
    return @{@"node": _allNodes[index],
             @"leftRange":[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(range.location, index - 1 - range.location)],
             @"rightRange":[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index + 1, range.location + range.length - index - 1)]};
}

- (void) startBalancingInContext:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.preferedNodeEntityName];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES]];
    NSError *error = nil;
    
    self.allNodes = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        medianIndex = -1;
        return;
    }
    medianIndex = _allNodes.count * 0.5;
    DTNodeX *medianNode = _allNodes[medianIndex];
    self.rootNode = medianNode;
    medianNode.leftCount = medianIndex;
    medianNode.rightCount = _allNodes.count - medianIndex;
    self.unbalancedNodes = [@[[self unbalancedNodeRecordAtIndex:medianIndex WithinRange:NSMakeRange(0, _allNodes.count)]] mutableCopy];
}

/* Idea of median balancing:
 
 0
  \                       3        |           3
   2           |         / \      012         / \     => tada!
  / \    => 0123489 => 012 489 =>  ^  =>     1   8
 1   3         ^                            /|   |\
      \      median            =>  |  =>   0 2   4 9
       8  (center element)        489
      / \                          ^
     4   9
 */

- (BOOL) iterateBalancing:(NSNumber *) times {
    int timesLeft = [times integerValue];
    while (timesLeft--) {
        if (_unbalancedNodes.count == 0)
            return NO;
        NSDictionary *nodeRecord = _unbalancedNodes.lastObject;
        [_unbalancedNodes removeLastObject];
        DTNodeX *node = nodeRecord[@"node"];
        [rangeNames enumerateObjectsUsingBlock:^(NSString *rangeName, NSUInteger idx, BOOL *stop) {
            NSIndexSet *indexes = nodeRecord[rangeName];
            NSUInteger start = indexes.firstIndex;
            NSUInteger len = indexes.count;
            if (len > 1) {
                int median = start + (len*0.5);
                [node setNode:_allNodes[median] BySide:(BranchSide)idx];
                [_unbalancedNodes addObject:[self unbalancedNodeRecordAtIndex:median WithinRange:NSMakeRange(start, len)]];
            } else {
                if (len > 0) {
                    [node setNode:_allNodes[start] BySide:(BranchSide)idx];
                    [_allNodes[start] terminateAllConnections];
                } else
                    [node setNode:nil BySide:(BranchSide)idx];
            }
            [node setCount:len BySide:(BranchSide)idx];
        }];
    }
    return YES;
}

- (void) cancelBalancing {
    if (self.unbalancedNodes)
        while (self.unbalancedNodes.count > 0) {
            NSDictionary *nodeRec = self.unbalancedNodes.lastObject;
            DTNodeX *startingNode = nodeRec[@"node"];
            for (NSString *rangeName in rangeNames) {
                [self.allNodes enumerateObjectsAtIndexes:nodeRec[rangeName] options:0 usingBlock:^(DTNodeX *node, NSUInteger idx, BOOL *stop) {
                    [startingNode addNewNode:node];
                }];
            }
            [self.unbalancedNodes removeLastObject];
        }
}

- (id) initWithEntity:(NSEntityDescription *)entity insertIntoManagedObjectContext:(NSManagedObjectContext *)context {
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self) {
        if ([entity.name isEqualToString:@"GraphX"])
            self.preferedNodeEntityName = @"NodeX";
        else
            self.preferedNodeEntityName = @"NodeY";
        rangeNames = @[@"leftRange", @"rightRange"];
    }
    return self;
}

@end
