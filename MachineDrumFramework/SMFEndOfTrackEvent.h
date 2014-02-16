//
//  SMFEndOfTrackEvent.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 12/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "SMFEvent.h"

@interface SMFEndOfTrackEvent : SMFEvent
+ (instancetype) smfEndOfTrackEventWithAbsoluteTick:(NSUInteger)tick;
+ (instancetype) smfEndOfTrackEventWithDelta:(NSUInteger)tick;
@end
