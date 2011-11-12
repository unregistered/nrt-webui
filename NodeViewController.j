/*
 * NodeView.j
 * nrt-webui
 *
 * Created by Chris Li on November 11, 2011.
 * Copyright 2011, All rights reserved.
 */

@import <AppKit/CPView.j>

@implementation NodeViewController : CPViewController
{
	IBOutlet CPTextField nodeLabel;
	Node node;
}

- (id)initWithNode:(Node)aNode atLocation:aLocation{
	[self initWithCibName:@"Node" bundle:[CPBundle mainBundle]];
	node = aNode;
		
	[[self view] setFrame:CGRectMake(aLocation.x-300, aLocation.y-100, 100, 100)];
	return self;
}

- (void)awakeFromCib{
	[nodeLabel setStringValue:[node name]];
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{	
    // var data = [[aSender draggingPasteboard] dataForType:NodeDragType];
    //     var payload = [CPKeyedUnarchiver unarchiveObjectWithData:data];
    // 
    // 	var destination = [aSender draggingLocation];
    // 	
    // 	
	
    //[_paneLayer setImage:[CPKeyedUnarchiver unarchiveObjectWithData:data]];
}

@end
