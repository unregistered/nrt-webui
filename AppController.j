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
@import "CanvasViewController.j"
@import "CanvasView.j"
@import "NodeView.j"
@import "NodeViewController.j"

@implementation AppController : CPObject
{
    IBOutlet CPWindow theWindow; //this "outlet" is connected automatically by the Cib
	IBOutlet CPCollectionView collectionView;
	IBOutlet CPScrollView scrollView;
	IBOutlet CPView leftView;
}

// This is called when the application is done loading.
- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
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
