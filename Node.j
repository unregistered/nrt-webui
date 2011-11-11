/*
 * Node.j
 * nrt-webui
 *
 * Created by Chris Li on November 8, 2011.
 * Copyright 2011, All rights reserved.
 */

@import <Foundation/CPObject.j>

@implementation Node : CPObject
{
	CPString name @accessors;
	CPArray inputs @accessors;
	CPArray outputs @accessors;
}

- (void)init {
	self = [super init];
	
	return self;
}

- (id)initWithName:(CPString)aName inputs:(CPArray)aInputs outputs:(CPArray)aOutputs {
	self.name = aName;
	self.inputs = aInputs;
	self.outputs = aOutputs;
	return self;
}

@end
