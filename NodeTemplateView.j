/*
 * NodeTemplateView.j
 * nrt-webui
 *
 * Created by Chris Li on November 8, 2011.
 * Copyright 2011, All rights reserved.
 */

@import <AppKit/CPView.j>

@implementation NodeTemplateView : CPView
{
	IBOutlet CPTextField nodeName;
	IBOutlet CPTextField inputCount;
	IBOutlet CPTextField outputCount;
}

- (void)setSelected:(BOOL)isSelected
{
    [self setBackgroundColor:isSelected ? [CPColor grayColor] : nil];
}

- (void)setRepresentedObject:(id)anObject
{	
	if(!nodeName)
		nodeName = [self viewWithTag:100];
	if(!inputCount)
		inputCount = [self viewWithTag:200];
	if(!outputCount)
		outputCount = [self viewWithTag:300];
	
	[nodeName setStringValue:[anObject name]];
	[inputCount setStringValue:[anObject inputs].length];
	[outputCount setStringValue:[anObject outputs].length];
	
	
	
	
	//[view addSubview:anObject];
    // if (!_imageView)
    //     {
    //         _imageView = [[CPImageView alloc] initWithFrame:CGRectInset([self bounds], 5.0, 5.0)];
    //         
    //         [_imageView setImageScaling:CPScaleProportionally];
    //         [_imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    //         
    //         [self addSubview:_imageView];
    //     }
    //     
    //     [_imageView setImage:anObject];
}


@end
