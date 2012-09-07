//
//  MDValuePair.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/3/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDValuePair.h"

@implementation MDValuePair
+ (id)valuePairWithX:(float)x y:(float)y
{
	MDValuePair *vp = [MDValuePair new];
	vp.x = x;
	vp.y = y;
	return vp;
}
@end
