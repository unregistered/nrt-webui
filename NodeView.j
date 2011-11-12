/*
 * NodeView.j
 * nrt-webui
 *
 * Created by Chris Li on November 11, 2011.
 * Copyright 2011, All rights reserved.
 */

@import <AppKit/CPView.j>

@implementation NodeView : CPView
{
}

-(void) awakeFromCib{
	CPLog("view");
	// [self registerForDraggedTypes:[NodeDragType]];
}

// - (void)performDragOperation:(CPDraggingInfo)aSender
// {	
//     var data = [[aSender draggingPasteboard] dataForType:NodeDragType];
//     var payload = [CPKeyedUnarchiver unarchiveObjectWithData:data];
// 
// 	var destination = [aSender draggingLocation];
// 	
// 	CPLog(payload);
// 	var n = [[CPBox alloc] initWithFrame:CGRectMake(destination.x-300,destination.y-100,100,100)];
// 	CPLog(n);
// 	[self addSubview:n];
// 	
// 	
// 	
//     //[_paneLayer setImage:[CPKeyedUnarchiver unarchiveObjectWithData:data]];
// }

@end
