//
//  PGMidi.m
//  PGMidi
//

#import "PGMidi.h"
#import "MidiInputParser.h"
#import "MDSysexUtil.h"
#import <mach/mach_time.h>

#if TARGET_OS_IPHONE
#import <CoreMIDI/MIDINetworkSession.h>
#endif

/// A helper that NSLogs an error message if "c" is an error code
#define NSLogError(c,str) do{if (c) NSLog(@"Error (%@): %ld:%@", str, (long)c,[NSError errorWithDomain:NSMachErrorDomain code:c userInfo:nil]);}while(false)

//==============================================================================
// ARC


//==============================================================================

static void PGMIDINotifyProc(const MIDINotification *message, void *refCon);
static void PGMIDIReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon);

@interface PGMidi ()
- (void) scanExistingDevices;
- (MIDIPortRef) outputPort;
@end

//==============================================================================

#if TARGET_OS_IPHONE
static
BOOL IsNetworkSession(MIDIEndpointRef ref)
{
    MIDIEntityRef entity = 0;
    MIDIEndpointGetEntity(ref, &entity);
	
    BOOL hasMidiRtpKey = NO;
    CFPropertyListRef properties = nil;
    OSStatus s = MIDIObjectGetProperties(entity, &properties, true);
    if (!s)
    {
        NSDictionary *dictionary = (__bridge  NSDictionary *) properties;
        hasMidiRtpKey = [dictionary valueForKey:@"apple.midirtp.session"] != nil;
        CFRelease(properties);
    }
	
    return hasMidiRtpKey;
}
#endif


static
NSString *NameOfEndpoint(MIDIEndpointRef ref)
{
    NSString *string = nil;

    MIDIEntityRef entity = 0;
    MIDIEndpointGetEntity(ref, &entity);

    //CFPropertyListRef properties = nil;
	CFStringRef displayNameStringRef = nil;
	OSStatus s = MIDIObjectGetStringProperty(entity, kMIDIPropertyName, &displayNameStringRef);
    //OSStatus s = MIDIObjectGetProperties(entity, &properties, true);
    if (s)
    {
		NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:s userInfo:nil];
		DLog(@"err: %@", error);
        string = @"Unknown name";
    }
    else
    {
        //NSLog(@"Properties = %@", properties);
		//NSDictionary *dictionary = (__bridge NSDictionary *)properties;
		string = (__bridge NSString *)displayNameStringRef;
#if TARGET_OS_IPHONE
		if(IsNetworkSession(ref))
			string = [NSString stringWithFormat:@"Network %@", string];
#endif
		
        //string = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"displayname"]];
        //CFRelease(properties);
		CFRelease(displayNameStringRef);
    }

    return string;
}

//==============================================================================




@implementation PGMidiConnection

- (id) initWithMidi:(PGMidi*)m endpoint:(MIDIEndpointRef)e
{
    if ((self = [super init]))
    {
        _midi                = m;
        _endpoint            = e;
        _name                = NameOfEndpoint(e);
#if TARGET_OS_IPHONE
		 _isNetworkSession  = IsNetworkSession(e);
#endif
    }
    return self;
}

@end

//==============================================================================

@implementation PGMidiSource

- (id) initWithMidi:(PGMidi*)m endpoint:(MIDIEndpointRef)e
{
    if ((self = [super initWithMidi:m endpoint:e]))
    {
		self.parser = [MidiInputParser new];
		self.parser.source = self;
		self.delegate = self.parser;
		
		//DLog(@"parser: %@", self.parser);
    }
    return self;
}

// NOTE: Called on a separate high-priority thread, not the main runloop
- (void) midiRead:(const MIDIPacketList *)pktlist
{
	if(_parser.delegate)
		[_delegate midiSource:self midiReceived:pktlist];
}

static
void PGMIDIReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon)
{
    PGMidiSource *self = (__bridge PGMidiSource *)srcConnRefCon;
    [self midiRead:pktlist];
}

@end

//==============================================================================

@interface PGMidiDestination()
{
	BOOL _sysexQueueRunning;
}
@property (strong, nonatomic) NSMutableArray *sysexQueue;
@end

@implementation PGMidiDestination


- (id) initWithMidi:(PGMidi*)m endpoint:(MIDIEndpointRef)e
{
    if ((self = [super initWithMidi:m endpoint:e]))
    {
        _midi     = m;
        _endpoint = e;
		self.sysexQueue = [NSMutableArray array];
    }
    return self;
}

- (void)sendNoteOn:(MidiNoteOn)noteOn
{
	
	noteOn.channel = 0x90 | noteOn.channel;
	const uint8_t bytes[3] = {noteOn.channel, noteOn.note, noteOn.velocity};
	[self sendBytes: bytes size:3];
}

- (void)sendNoteOff:(MidiNoteOff)noteOff
{
	noteOff.channel = 0x80 | (noteOff.channel & 0x0F);
	[self sendBytes:(uint8_t *) & noteOff size:3];
}

- (void)sendControlChange:(MidiControlChange)cc
{
	cc.channel = 0xB0 | (cc.channel & 0x0F);
	[self sendBytes:(uint8_t *) & cc size:3];
}

- (void)sendPitchWheel:(MidiPitchWheel)pw
{
	uint8_t bytes[3];
	bytes[0] = 0xE0 | (pw.channel & 0x0F);
	UInt16 pitch = pw.pitch;
	bytes[1] = pitch & 0x7F;
	bytes[2] = (pitch >> 7) & 0x7F;
	[self sendBytes:bytes size:3];
}

- (void) sendBytes:(const UInt8*)bytes size:(UInt32)size
{
    //NSLog(@"%s(%u bytes to core MIDI)", __func__, unsigned(size));
    assert(size < 65536);
    Byte packetBuffer[size+100];
    MIDIPacketList *packetList = (MIDIPacketList*)packetBuffer;
    MIDIPacket     *packet     = MIDIPacketListInit(packetList);
    packet = MIDIPacketListAdd(packetList, sizeof(packetBuffer), packet, 0, size, bytes);
    [self sendPacketList:packetList];
}

- (void) sendPacketList:(const MIDIPacketList *)packetList
{
    // Send it
    OSStatus s = MIDISend(_midi.outputPort, _endpoint, packetList);
    NSLogError(s, @"Sending MIDI");
}

static
void sysexSendCompletionProc(MIDISysexSendRequest *request)
{
	DLog(@"sysex send %@", request->complete ? @"succeeded" : @"failed");
	free(request);
}

- (void) sendSysexBytes:(const UInt8*)bytes size:(UInt32)size
{
	//DLog(@"sending %ld sysex bytes to %@", size, self.name);
//	assert(size < 65536);
	
	MIDISysexSendRequest *r = (MIDISysexSendRequest *) malloc(sizeof(MIDISysexSendRequest) + size);
	Byte *copiedBytes = (Byte *)r+sizeof(MIDISysexSendRequest);
	memcpy(copiedBytes, bytes, size);
	r->destination = self.endpoint;
	r->data = copiedBytes;
	r->bytesToSend = size;
	r->complete = FALSE;
	r->completionProc = sysexSendCompletionProc;
	r->completionRefCon = (__bridge void *) self;
	
	OSStatus err = MIDISendSysex(r);
	if(err)
	{
		DLog(@"sysex send error: %ld", err);
		free(r);
	}
}

- (void)sendSysexData:(NSData *)d
{
	NSArray *individualMessages = [MDSysexUtil splitDataFromData:d];
	for (NSData *data in individualMessages)
	{
		[self enqueueSysexData:data];
	}
	if(!_sysexQueueRunning)
		[self dequeueSysexQueue:nil];
}

- (void) enqueueSysexData:(NSData *)data
{
	[self.sysexQueue addObject:data];
}

- (void) dequeueSysexQueue:(NSTimer *)t
{
	if(!self.sysexQueue.count) return;	
	NSData *data = self.sysexQueue[0];
	[self.sysexQueue removeObjectAtIndex:0];
	[self sendSysexDataUsingMidiSend:data];
	
	if(self.sysexQueue.count)
	{
		_sysexQueueRunning = YES;
		NSTimeInterval time = (data.length / 31500.0) / 100;
		[NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(dequeueSysexQueue:) userInfo:nil repeats:NO];
	}
	else
	{
		_sysexQueueRunning = NO;
	}
}


static inline uint64_t convertNanosecondsToTimestamp(uint64_t time)
{
    const int64_t kOneThousand = 1000;
    static mach_timebase_info_data_t s_timebase_info;
	
    if (s_timebase_info.denom == 0)
    {
        (void) mach_timebase_info(&s_timebase_info);
    }
	
    return (uint64_t)((time * s_timebase_info.numer) * (kOneThousand * s_timebase_info.denom));
}

static inline uint64_t convertTimestampToNanoseconds(uint64_t time)
{
    const int64_t kOneThousand = 1000;
    static mach_timebase_info_data_t s_timebase_info;
	
    if (s_timebase_info.denom == 0)
    {
        (void) mach_timebase_info(&s_timebase_info);
    }
	
    // mach_absolute_time() returns billionth of seconds,
    // so divide by one thousand to get nanoseconds
    return (uint64_t)((time * s_timebase_info.numer) / (kOneThousand * s_timebase_info.denom));
}


- (void) sendSysexDataUsingMidiSend:(NSData *)d
{
	const uint8_t *bytes = d.bytes;
	NSUInteger len = d.length;
	NSUInteger idx = 0;
	
	NSUInteger packetListLength = 256;
	NSUInteger currentLen = packetListLength;
	size_t packetListSize = sizeof(MIDIPacketList);
	
	while(idx < len)
	{
		NSInteger l = len - idx;
		if(l >= packetListLength) currentLen = packetListLength;
		else if(l <= 0) break;
		else if(l < packetListLength) currentLen = l;
		const uint8_t *packetBytes = &(bytes[idx]);
		MIDIPacketList packetlist = {};
		MIDIPacket *packet = MIDIPacketListInit(&packetlist);
		packet = MIDIPacketListAdd(&packetlist, packetListSize, packet, 0, currentLen, packetBytes);
		[self sendPacketList:&packetlist];
		idx+= packetListLength;
	}
}

- (void) sendSysexDataUsingSysexSend:(NSData *)d
{
	const uint8_t *bytes = d.bytes;
	UInt32 len = d.length;
	[self sendSysexBytes:bytes size:len];
}

@end

//==============================================================================

@implementation PGMidi

@synthesize sources,destinations;


+ (PGMidi *)sharedInstance
{
	static PGMidi *_default = nil;
	if(_default != nil) return _default;
	
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
				  {
					  _default = [[PGMidi alloc] init];
				  });
	
	
	return _default;
}

- (id) init
{
    if ((self = [super init]))
    {
        sources      = [NSMutableArray new];
        destinations = [NSMutableArray new];

        OSStatus s = MIDIClientCreate((CFStringRef)@"MidiMonitor MIDI Client", PGMIDINotifyProc, (__bridge void *)self, &client);
        NSLogError(s, @"Create MIDI client");

        s = MIDIOutputPortCreate(client, (CFStringRef)@"MidiMonitor Output Port", &outputPort);
        NSLogError(s, @"Create output MIDI port");

        s = MIDIInputPortCreate(client, (CFStringRef)@"MidiMonitor Input Port", PGMIDIReadProc, (__bridge void *) self, &inputPort);
        NSLogError(s, @"Create input MIDI port");

        [self scanExistingDevices];
    }

    return self;
}

- (void) dealloc
{
    if (outputPort)
    {
        MIDIPortDispose(outputPort);
        //NSLogError(s, @"Dispose MIDI port");
    }

    if (inputPort)
    {
        MIDIPortDispose(inputPort);
        //NSLogError(s, @"Dispose MIDI port");
    }

    if (client)
    {
        MIDIClientDispose(client);
        //NSLogError(s, @"Dispose MIDI client");
    }
}

- (NSUInteger) numberOfConnections
{
    return sources.count + destinations.count;
}

- (MIDIPortRef) outputPort
{
    return outputPort;
}

#if TARGET_OS_IPHONE
- (void) enableNetwork:(BOOL)enabled
{
    MIDINetworkSession* session = [MIDINetworkSession defaultSession];
    session.enabled = enabled;
    session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
}
#endif

//==============================================================================
#pragma mark Connect/disconnect

- (PGMidiSource*) getSource:(MIDIEndpointRef)source
{
    for (PGMidiSource *s in sources)
    {
        if (s.endpoint == source) return s;
    }
    return nil;
}

- (PGMidiDestination*) getDestination:(MIDIEndpointRef)destination
{
    for (PGMidiDestination *d in destinations)
    {
        if (d.endpoint == destination) return d;
    }
    return nil;
}

- (void) connectSource:(MIDIEndpointRef)endpoint
{
    PGMidiSource *source = [[PGMidiSource alloc] initWithMidi:self endpoint:endpoint];
    [sources addObject:source];

	if([_delegate respondsToSelector:@selector(midiSourceAdded:)])
		[_delegate midiSourceAdded:source];

    OSStatus s = MIDIPortConnectSource(inputPort, endpoint, (__bridge void *)source);
    NSLogError(s, @"Connecting to MIDI source");
}

- (void) disconnectSource:(MIDIEndpointRef)endpoint
{
    PGMidiSource *source = [self getSource:endpoint];

    if (source)
    {
        OSStatus s = MIDIPortDisconnectSource(inputPort, endpoint);
        NSLogError(s, @"Disconnecting from MIDI source");
        if([_delegate respondsToSelector:@selector(midiSourceRemoved:)])
			[_delegate midiSourceRemoved:source];
        [sources removeObject:source];
    }
}

- (void) connectDestination:(MIDIEndpointRef)endpoint
{
    PGMidiDestination *destination = [[PGMidiDestination alloc] initWithMidi:self endpoint:endpoint];
    [destinations addObject:destination];
	if([_delegate respondsToSelector:@selector(midiDestinationAdded:)])
		[_delegate midiDestinationAdded:destination];
}

- (void) disconnectDestination:(MIDIEndpointRef)endpoint
{
    //[delegate midiInput:self event:@"Removed a device"];

    PGMidiDestination *destination = [self getDestination:endpoint];

    if (destination)
    {
		if([_delegate respondsToSelector:@selector(midiDestinationRemoved:)])
			[_delegate midiDestinationRemoved:destination];
        [destinations removeObject:destination];
    }
}

- (void) scanExistingDevices
{
    const ItemCount numberOfDestinations = MIDIGetNumberOfDestinations();
    const ItemCount numberOfSources      = MIDIGetNumberOfSources();

    for (ItemCount index = 0; index < numberOfDestinations; ++index)
        [self connectDestination:MIDIGetDestination(index)];
    for (ItemCount index = 0; index < numberOfSources; ++index)
        [self connectSource:MIDIGetSource(index)];
}

//==============================================================================
#pragma mark Notifications

- (void) midiNotifyAdd:(const MIDIObjectAddRemoveNotification *)notification
{
    if (notification->childType == kMIDIObjectType_Destination)
        [self connectDestination:(MIDIEndpointRef)notification->child];
    else if (notification->childType == kMIDIObjectType_Source)
        [self connectSource:(MIDIEndpointRef)notification->child];
}

- (void) midiNotifyRemove:(const MIDIObjectAddRemoveNotification *)notification
{
    if (notification->childType == kMIDIObjectType_Destination)
        [self disconnectDestination:(MIDIEndpointRef)notification->child];
    else if (notification->childType == kMIDIObjectType_Source)
        [self disconnectSource:(MIDIEndpointRef)notification->child];
}

- (void) midiNotify:(const MIDINotification*)notification
{
    switch (notification->messageID)
    {
        case kMIDIMsgObjectAdded:
            [self midiNotifyAdd:(const MIDIObjectAddRemoveNotification *)notification];
            break;
        case kMIDIMsgObjectRemoved:
            [self midiNotifyRemove:(const MIDIObjectAddRemoveNotification *)notification];
            break;
        case kMIDIMsgSetupChanged:
        case kMIDIMsgPropertyChanged:
        case kMIDIMsgThruConnectionsChanged:
        case kMIDIMsgSerialPortOwnerChanged:
        case kMIDIMsgIOError:
            break;
    }
}

void PGMIDINotifyProc(const MIDINotification *message, void *refCon)
{
    PGMidi *self = (__bridge PGMidi *)refCon;
    [self midiNotify:message];
}

//==============================================================================
#pragma mark MIDI Output

- (void) sendPacketList:(const MIDIPacketList *)packetList
{
    for (ItemCount index = 0; index < MIDIGetNumberOfDestinations(); ++index)
    {
        MIDIEndpointRef outputEndpoint = MIDIGetDestination(index);
        if (outputEndpoint)
        {
            // Send it
            OSStatus s = MIDISend(outputPort, outputEndpoint, packetList);
            NSLogError(s, @"Sending MIDI");
        }
    }
}

- (void) sendBytes:(const UInt8*)data size:(UInt32)size
{
    //NSLog(@"%s(%u bytes to core MIDI)", __func__, unsigned(size));
    assert(size < 65536);
    Byte packetBuffer[size+100];
    MIDIPacketList *packetList = (MIDIPacketList*)packetBuffer;
    MIDIPacket     *packet     = MIDIPacketListInit(packetList);

    packet = MIDIPacketListAdd(packetList, sizeof(packetBuffer), packet, 0, size, data);

    [self sendPacketList:packetList];
}

@end
