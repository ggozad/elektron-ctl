//
//  MyMidiFoundation.m
//  sysexingApp
//
//  Created by Jakob Penca on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "MDMidiFoundation.h"
#import "MDKit.h"
#import "MDSysexUtil.h"
#import "MDMachinedrumPublic.h"

#define kElektronTM1DisplayName @"Elektron TM-1"
#define kDesiredSysexSpeed 3125

static void SetGetSpeed(MIDIEndpointRef ep, SInt32 speed)
{
	SInt32 oldSpeed = 0;
	MIDIObjectGetIntegerProperty(ep, kMIDIPropertyMaxSysExSpeed, &oldSpeed);
	MIDIObjectSetIntegerProperty(ep, kMIDIPropertyMaxSysExSpeed, speed);
	SInt32 speed2 = 0;
	MIDIObjectGetIntegerProperty(ep, kMIDIPropertyMaxSysExSpeed, &speed2);
	DLog(@"changing midi sysex send speed from %d B/s to %d B/s. Result: %d B/s", oldSpeed, speed, speed2);
}

static NSString *getDisplayName(MIDIObjectRef object)
{
	// Returns the display name of a given MIDIObjectRef as an NSString
	CFStringRef name = nil;
	if (noErr != MIDIObjectGetStringProperty(object, kMIDIPropertyDisplayName, &name))
		return nil;
	return (__bridge NSString *)name;
}

@interface MDMidiFoundation()

@property MIDIEndpointRef midiEndPointRefForOutput;
@property MIDIEndpointRef midiEndPointRefForInput;
@property MIDIPortRef midiInPortRef;
@property MIDIClientRef midiClientRef;
@property MIDISysexSendRequest *midiSysexSendRequest;

@property (strong, nonatomic) NSMutableArray *sysexSendQueueArray;


- (BOOL) autoSetup;
- (BOOL) setupDestination:(MIDIEndpointRef)i;
- (BOOL) setupSource:(MIDIEndpointRef)i;
- (void) handleIncomingSysexMessageData:(NSData *)data;
- (void) sendSysexData:(NSData *)data;
- (void) dequeueAndSendData;

@end


@implementation MDMidiFoundation
@synthesize
midiEndPointRefForOutput,
midiEndPointRefForInput,
midiInPortRef,
midiClientRef,
midiSysexSendRequest, ready, tempo;


- (NSUInteger)sysexQueueLength
{
	return [self.sysexSendQueueArray count];
}

- (void)dequeueAndSendData
{
	if(!self.ready) return;
	if(!self.sysexSendQueueArray.count) return;
	
	NSData *d = [self.sysexSendQueueArray objectAtIndex:0];
	if(d)
	{
		[self.sysexSendQueueArray removeObject:d];
	}
	
	[self performSelectorOnMainThread:@selector(sendSysexData:) withObject:d waitUntilDone:NO];
}

- (void)enqueueSysexMessage:(NSData *)data
{
	[self.sysexSendQueueArray addObject:data];
}



- (id)init
{
	if(self = [super init])
	{
		self.sysexSendQueueArray = [NSMutableArray array];
		[NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(dequeueAndSendData) userInfo:nil repeats:YES];
	}
	return self;
}

- (void)handleIncomingSysexMessageData:(NSData *)data
{
	NSString *stripped = @"";
	if(data.length <= 64)
	{
		stripped = [data description];
		stripped = [stripped stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
		stripped = [stripped stringByReplacingCharactersInRange:NSMakeRange(stripped.length-1, 1) withString:@""];
		stripped = [stripped stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
		//DLog(@"\n\n%@\n\n", stripped);
	}
	
	if(data.length <= 64)
		DLog(@"\n\n* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\n\nincoming sysex raw data (%ld bytes):\n\n%@\n\n", data.length, stripped);
		
	[MDSysexRouter routeSysexData:data];

}

- (void)sendTurboMidiSpeedRequest
{
	const signed char bytes[] = {0xf0, 0x00, 0x20, 0x3c, 0x00, 0x00, 0x10, 0xf7};
	[self sendSysexData:[NSData dataWithBytes:&bytes length:8]];
}

- (void)setup
{
	self.ready = [self autoSetup];
	[[NSNotificationCenter defaultCenter] postNotificationName:kMIDIFoundationReadyChange object:self];
}

- (BOOL)autoSetup
{
	
	OSStatus result = noErr;
	
	if(!self.midiClientRef)
	{
		MIDIClientRef clientRef;
		result = MIDIClientCreate(CFSTR("MIDI CLIENT"), midiNotifyProc, (__bridge void *)(self), &clientRef);
		self.midiClientRef = clientRef;
		if(result != noErr)
		{
			NSLog(@"failed to create midi client.. bailing.");
			return NO;
		}
	}
	
	DLog(@"looking for %@ device...", kElektronTM1DisplayName);
	
	BOOL success = NO;
	
	//DLog(@"Iterate through destinations");
	ItemCount destCount = MIDIGetNumberOfDestinations();
	for (ItemCount i = 0 ; i < destCount ; ++i) {
		
		// Grab a reference to a destination endpoint
		MIDIEndpointRef dest = MIDIGetDestination(i);
		if (dest)
		{
			NSString *displayname = getDisplayName(dest);
			DLog(@"  Destination: %@", displayname);
			if([displayname isEqualToString:kElektronTM1DisplayName])
				success = [self setupDestination:dest];
		}
	}
	
	NSMutableArray *destStrings = [NSMutableArray array];
	
	ItemCount sourceCount = MIDIGetNumberOfSources();
	for (ItemCount i = 0 ; i < sourceCount ; ++i)
	{
		
		MIDIEndpointRef source = MIDIGetSource(i);
		if (source)
		{
			NSString *displayname = getDisplayName(source);
			[destStrings addObject:displayname];
			DLog(@"  Destination: %@", displayname);
			if([displayname isEqualToString:kElektronTM1DisplayName])
			{
				success = [self setupSource:source];
			}
				
		}
	}
	
	DLog(@"%@ %@found, autosetup %@", kElektronTM1DisplayName, success ? @"" : @"not ", success ? @"succeeded." : @"failed.");
	
	
	return success;
}

- (BOOL)setupDestination:(MIDIEndpointRef)i
{
	self.midiEndPointRefForOutput = i;
	SetGetSpeed(self.midiEndPointRefForOutput, kDesiredSysexSpeed);
	return YES;
}

- (BOOL)setupSource:(MIDIEndpointRef)i
{
	self.midiEndPointRefForInput = i;
	
	OSStatus result = noErr;
	
	if(!self.midiClientRef)
	{
		MIDIClientRef clientRef;
		result = MIDIClientCreate(CFSTR("MIDI CLIENT"), midiNotifyProc, (__bridge void *)(self), &clientRef);
		self.midiClientRef = clientRef;
		if(result != noErr)
		{
			NSLog(@"failed to create midi client.. bailing.");
			return NO;
		}
	}
	
	
	MIDIPortRef inPortRef;
	result = MIDIInputPortCreate(self.midiClientRef, CFSTR("Input"), midiInputCallback, (__bridge void *)(self), &inPortRef);
	self.midiInPortRef = inPortRef;
	if(result != noErr)
	{
		NSLog(@"failed to create midi inport ref.. bailing.");
		return NO;
	}

	
	result = MIDIPortConnectSource(self.midiInPortRef, self.midiEndPointRefForInput, NULL);
	if(result != noErr)
	{
		NSLog(@"failed to connect source.. bailing.");
		return NO;
	}

	
	return YES;
}


- (void)sendSysexData:(NSData *)data
{
	DLog(@"sending sysex.");
	self.ready = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:kMIDIFoundationReadyChange object:self];
	
	self.exchangingMidiData = YES;
	UInt32 length = (UInt32)[data length];
	const unsigned char *bytes = data.bytes;
	NSAssert(self.midiEndPointRefForOutput, @"no midi endpoint!");
	
	if(self.midiSysexSendRequest) free(self.midiSysexSendRequest);
	
	self.midiSysexSendRequest = calloc(1, sizeof(MIDISysexSendRequest));
	self.midiSysexSendRequest->destination = self.midiEndPointRefForOutput;
	self.midiSysexSendRequest->data = bytes;
	self.midiSysexSendRequest->bytesToSend = length;
	self.midiSysexSendRequest->complete = 0;
	self.midiSysexSendRequest->completionProc = sysexSendCompletionProc;
	self.midiSysexSendRequest->completionRefCon = (__bridge void *)(self);
	
	MIDISendSysex(self.midiSysexSendRequest);
}



- (void) midiNotifyAdd:(const MIDIObjectAddRemoveNotification *)notification
{
    if (notification->childType == kMIDIObjectType_Destination)
	{
		MIDIEndpointRef endPoint = notification->child;
		if([getDisplayName(endPoint) isEqualToString:kElektronTM1DisplayName])
		{
			self.midiEndPointRefForOutput = endPoint;
			SetGetSpeed(self.midiEndPointRefForOutput, kDesiredSysexSpeed);
			
			ItemCount sourceCount = MIDIGetNumberOfSources();
			for (ItemCount i = 0 ; i < sourceCount ; ++i)
			{
				
				MIDIEndpointRef source = MIDIGetSource(i);
				if (source)
				{
					NSString *displayname = getDisplayName(source);
					//DLog(@"  Destination: %@", displayname);
					if([displayname isEqualToString:kElektronTM1DisplayName])
					{
						DLog(@"connecting %@", kElektronTM1DisplayName);
						self.ready = [self setupSource:source];
						[[NSNotificationCenter defaultCenter] postNotificationName:kMIDIFoundationReadyChange object:self];
					}
				}
			}
		}
	}
}

- (void) midiNotifyRemove:(const MIDIObjectAddRemoveNotification *)notification
{
    if (notification->childType == kMIDIObjectType_Destination)
	{
		MIDIEndpointRef endPoint = notification->child;
		if([getDisplayName(endPoint) isEqualToString:kElektronTM1DisplayName])
		{
			DLog(@"disconnecting %@", kElektronTM1DisplayName);
			OSStatus err = noErr;
			
			err = MIDIPortDisconnectSource(self.midiInPortRef, self.midiEndPointRefForInput);
			if(err)DLog(@"error disconnecting source");
			
			err = MIDIPortDispose(self.midiInPortRef);
			if(err)DLog(@"error disposing in-port");
			
			
			self.midiEndPointRefForInput = 0;
			self.midiEndPointRefForOutput = 0;
			self.midiInPortRef = 0;
			self.ready = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:kMIDIFoundationReadyChange object:self];
		}
	}
}


@end



void sysexSendCompletionProc(MIDISysexSendRequest *request)
{
	if(request->complete)
	{
		DLog(@"sysex send complete");
	}
	else
	{
		DLog(@"sysex send did something stupid");
	}
	
	MDMidiFoundation *slf = (__bridge MDMidiFoundation *)(request->completionRefCon);
	slf.ready = YES;
	[[NSNotificationCenter defaultCenter] postNotificationName:kMIDIFoundationReadyChange object:slf];
	slf.exchangingMidiData = NO;
}

void midiNotifyProc(const MIDINotification *notification, void *refCon)
{
	MDMidiFoundation *slf = (__bridge MDMidiFoundation *)refCon;
	switch (notification->messageID)
    {
        case kMIDIMsgObjectAdded:
            [slf midiNotifyAdd:(const MIDIObjectAddRemoveNotification *)notification];
            break;
        case kMIDIMsgObjectRemoved:
            [slf midiNotifyRemove:(const MIDIObjectAddRemoveNotification *)notification];
            break;
        case kMIDIMsgSetupChanged:
        case kMIDIMsgPropertyChanged:
        case kMIDIMsgThruConnectionsChanged:
        case kMIDIMsgSerialPortOwnerChanged:
        case kMIDIMsgIOError:
            break;
    }
}

#define bufSize (1024*1024)
signed char inBytesSysexBuffer[1024 * 1024];
NSUInteger inBytesSysexBufferIndex = 0;
BOOL receivingSysexData = NO;
NSUInteger bytesToSkip = 0;

#define MD_MIDI_STATUS_SYSEX_BEGIN (0xf0)
#define MD_MIDI_STATUS_SYSEX_END (0xf7)
#define MD_MIDI_STATUS_CLOCK (0xf8)
#define MD_MIDI_STATUS_ACTIVESENSE (0xfe)
#define MD_MIDI_STATUS_ANY (0x80)
#define MD_MIDI_STATUS_NOTE_ON (0x90)

void midiInputCallback (const MIDIPacketList *list,
						 void *procRef,
						 void *srcRef)
{
	const MIDIPacket *currentPacket = &list->packet[0];
	
	BOOL logStuff = [(__bridge MDMidiFoundation *)procRef logMidiEvents];
	
	
	//DLog(@" * * * ");
	
	//loop through packets
	for (NSUInteger currentPacketIndex = 0; currentPacketIndex < list->numPackets; currentPacketIndex++)
	{
		// loop through bytes
		for (NSUInteger currentByteIndex = 0; currentByteIndex < currentPacket->length; currentByteIndex++)
		{
			unsigned char byteValue = currentPacket->data[currentByteIndex];
			
			if(byteValue == MD_MIDI_STATUS_SYSEX_BEGIN)
			{
				//DLog(@"sysex receive begin...");
			}
			
			// handle MIDI status bytes
			if(byteValue & MD_MIDI_STATUS_ANY) // got status byte
			{
				if(byteValue == MD_MIDI_STATUS_CLOCK)
				{
					//DLog(@"got clock!");
				}
				else if(receivingSysexData &&
				   byteValue != MD_MIDI_STATUS_SYSEX_END &&
				   byteValue != MD_MIDI_STATUS_SYSEX_BEGIN) // something other than END or BEGIN while receiving
				{
					// handle interruption
					
					if(byteValue == MD_MIDI_STATUS_CLOCK) // clock signal
					{
						//DLog(@"received clock byte during sysex rceive, skipping 1 byte");
						//bytesToSkip += 1;
					}
					else if(byteValue == MD_MIDI_STATUS_ACTIVESENSE) // active sense
					{
						//DLog(@"received activesense byte during sysex rceive, skipping 1 byte");
						//bytesToSkip += 1;
					}
					else
					{
						DLog(@"received status byte during sysex receive: 0x%x", byteValue);
					}
				}
				else if(byteValue == MD_MIDI_STATUS_SYSEX_BEGIN) // sysex begin
				{
					if(receivingSysexData) // already receiving, starting fresh
					{
						DLog(@"already receiving sysex!");
						
					}
					receivingSysexData = YES;
					inBytesSysexBufferIndex = 0;
					bytesToSkip = 0;
					inBytesSysexBuffer[inBytesSysexBufferIndex++] = byteValue;
					//DLog(@"begin sysex receive");
				}
				else if (receivingSysexData && byteValue == MD_MIDI_STATUS_SYSEX_END) // sysex end
				{
					receivingSysexData = NO;
					inBytesSysexBuffer[inBytesSysexBufferIndex++] = byteValue;
					NSUInteger sysexDataLength = inBytesSysexBufferIndex;
					inBytesSysexBufferIndex = 0;
					//printf("\n");
					DLog(@"received sysex data with length: 0x%x", sysexDataLength);
					
					// copy data, notify receiver
					@autoreleasepool
					{
						NSData *d = [NSData dataWithBytes:&inBytesSysexBuffer length:sysexDataLength];
						[(__bridge MDMidiFoundation *)procRef performSelectorOnMainThread:@selector(handleIncomingSysexMessageData:)
																			   withObject:d
																			waitUntilDone:NO];
					}
				}
				else if (byteValue == MD_MIDI_STATUS_SYSEX_END)
				{
					DLog(@"received end message but wasn't receiving");
				}
				
				else
				{
					if(logStuff)
					{
						NSString *type = @"unknown";
						uint8_t loNib = byteValue & 0x0f;
						uint8_t hiNib = byteValue & 0xf0;
						
						if(hiNib == 0x80) type = [NSString stringWithFormat:@"note off @ chan %d", loNib];
						else if(hiNib == 0x90) type = [NSString stringWithFormat:@"note on @ chan %d", loNib];
						else if(hiNib == 0xA0) type = [NSString stringWithFormat:@"poly aftertouch @ chan %d", loNib];
						else if(hiNib == 0xB0) type = [NSString stringWithFormat:@"ctrl mode change @ chan %d", loNib];
						else if(hiNib == 0xC0) type = [NSString stringWithFormat:@"program change @ chan %d", loNib];
						else if(hiNib == 0xD0) type = [NSString stringWithFormat:@"chan aftertouch @ chan %d", loNib];
						else if(hiNib == 0xE0) type = [NSString stringWithFormat:@"pitch wheel range %d", loNib];
						else if(hiNib == 0xF0) type = [NSString stringWithFormat:@"sysex: 0x%x", loNib];
						
						DLog(@"received status byte: 0x%x type: %@", byteValue, type);
					}
				}
				 
			}
			// handle non-status bytes
			else
			{
				
				//DLog(@"non status byte: 0x%x", byteValue);
				
				if(receivingSysexData)
				{
					
					if(bytesToSkip)
					{
						bytesToSkip--; // skip
						DLog(@"skipping...");
					}
					else
					{
						// fill buffer
						inBytesSysexBuffer[inBytesSysexBufferIndex++] = byteValue;
						/*
						printf("%02x", byteValue);
						if(inBytesSysexBufferIndex)
						{
							if(inBytesSysexBufferIndex % 4 == 0)
							{
								printf(" ");
							}
							if(inBytesSysexBufferIndex % 32 == 0)
							{
								printf("\n");
							}
						}
						 */
						if(inBytesSysexBufferIndex >= bufSize)
						{
							DLog(@"buffer overflow!");
							inBytesSysexBufferIndex = 0;
							receivingSysexData = NO;
							bytesToSkip = 0;
						}
					}
				}
			}
		}
		currentPacket = MIDIPacketNext(currentPacket);
	}
}





















