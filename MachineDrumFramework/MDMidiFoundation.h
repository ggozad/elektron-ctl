//
//  MyMidiFoundation.h
//  sysexingApp
//
//  Created by Jakob Penca on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import "MDMachineDrum.h"
#import "MDSysexRouter.h"

void midiNotifyProc(const MIDINotification *message, void *refCon);
void sysexSendCompletionProc(MIDISysexSendRequest *request);
void midiInputCallback (const MIDIPacketList *list,
						void *procRef,
						void *srcRef);


@interface MDMidiFoundation : NSObject
@property int tempo;
@property BOOL ready;
@property BOOL exchangingMidiData;
@property float bpm;
@property BOOL logMidiEvents;


- (void) enqueueSysexMessage:(NSData *)data;
- (void) setup;
- (void) sendTurboMidiSpeedRequest;
- (NSUInteger) sysexQueueLength;

@end
