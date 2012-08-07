//
//  MDUserParameter.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 8/5/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MDUserParameterLimit.h"

typedef enum MDUserParameterWrapMode
{
	MDUserParameterWrapMode_Ignore,
	MDUserParameterWrapMode_Clamp,
	MDUserParameterWrapMode_Wrap
}
MDUserParameterWrapMode;

@interface MDUserParameterValue : NSObject
@property MDUserParameterLimit *limit;
@property MDUserParameterWrapMode wrapMode;
@property int8_t mutableValue;
@property int8_t innerValue;

- (void) resetToInnerValue;




@end
