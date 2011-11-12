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

// Needed for drag & drop
- (void)encodeWithCoder:(CPCoder)coder
{
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:inputs forKey:@"inputs"];
	[coder encodeObject:outputs forKey:@"outputs"];
}

-(id)initWithCoder:(CPCoder)coder
{
    if (self = [super init])
    {
		name = [coder decodeObjectForKey:@"name"];
		inputs = [coder decodeObjectForKey:@"inputs"];
		outputs = [coder decodeObjectForKey:@"outputs"];
	}
    
    return self;
}


@end
