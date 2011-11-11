/*
 * AppController.j
 * nrt-webui
 *
 * Created by Chris Li on November 8, 2011.
 * Copyright 2011, All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "Node.j"
@import "NodeLibraryDelegate.j"
@import "NodeTemplateView.j"

@implementation AppController : CPObject
{
    IBOutlet CPWindow theWindow; //this "outlet" is connected automatically by the Cib
	IBOutlet CPCollectionView collectionView;
	IBOutlet CPScrollView scrollView;
	IBOutlet CPView leftView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
	CPLog("Did finish launching");
	// bounds = [scrollView bounds];
    // bounds.size.height -= 20.0;
	// bounds.size.width -= 40.0;
	// CPLog(bounds);

    //[collectionView setAutoresizingMask:CPViewWidthSizable];
    //[collectionView setMinItemSize:CGSizeMake(100, 100)];
    //[collectionView setMaxItemSize:CGSizeMake(100, 100)];
    //[collectionView setDelegate:self];
    
    //var itemPrototype = [[CPCollectionViewItem alloc] init];
    //[itemPrototype setView:[[NodeTemplateView alloc] initWithFrame:CGRectMakeZero()]];
    //
    //[collectionView setItemPrototype:itemPrototype];
    
    // var scrollView = [[CPScrollView alloc] initWithFrame:bounds];
    //[scrollView setDocumentView:collectionView];
    //[scrollView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    //[scrollView setAutohidesScrollers:YES];
    //[[scrollView contentView] setBackgroundColor:[CPColor whiteColor]];

    
	templates = [
		[[Node alloc] initWithName:@"Input Node" inputs:[0] outputs:[1]],
		[[Node alloc] initWithName:@"Output Node" inputs:[1,2,3] outputs:[4]]
	];
	[collectionView setContent:templates];
	// [[[NodeLibrary alloc] init] orderFront:nil];
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things.
	
    // In this case, we want the window from Cib to become our full browser window
    [theWindow setFullPlatformWindow:YES];
}

@end
