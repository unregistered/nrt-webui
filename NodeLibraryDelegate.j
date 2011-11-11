/*
 * NodeLibrary.j
 * nrt-webui
 *
 * Created by Chris Li on November 8, 2011.
 * Copyright 2011, All rights reserved.
 */

@import <Foundation/CPObject.j>

NodeDragType = "NodeDragType"; // global var designates a node

@implementation NodeLibraryDelegate : CPObject
{
	IBOutlet CPCollectionView collectionView;
	CPArray templates;
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView
 dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
    return [NodeDragType];
}

- (CPData)collectionView:(CPCollectionView)aCollectionView
   dataForItemsAtIndexes:(CPIndexSet)indices
                 forType:(CPString)aType
{
    var firstIndex = [indices firstIndex];

	var node = [templates objectAtIndex:firstIndex];
    
    return [CPKeyedArchiver archivedDataWithRootObject:node];
}

- (void)awakeFromCib{
	templates = [
		[[Node alloc] initWithName:@"Input Node" inputs:[0] outputs:[1]],
		[[Node alloc] initWithName:@"Output Node" inputs:[1,2,3] outputs:[4]]
	];
	[collectionView setContent:templates];	
}


@end
