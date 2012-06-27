//
//  MDProcedureArpeggiator.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/27/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDProc.h"

typedef enum MDProcedureArpeggiatorWrapMode
{
	MDProcedureArpeggiatorWrapMode_WRAP,
}
MDProcedureArpeggiatorWrapMode;

typedef enum MDProcedureArpeggiatorDirection
{
	MDProcedureArpeggiatorDirection_UP,
	MDProcedureArpeggiatorDirection_DOWN
}
MDProcedureArpeggiatorDirection;

@interface MDProcedureArpeggiator : MDProc
@property uint8_t increment;
@property uint8_t startVal;
@property uint8_t stopVal;
@property uint8_t param;
@property MDProcedureArpeggiatorDirection direction;
@property MDProcedureArpeggiatorWrapMode wrapMode;
@end
