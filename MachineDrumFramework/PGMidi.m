//
//  PGMidi.m
//  PGMidi
//

#import "PGMidi.h"
#import "MidiInputParser.h"

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

@synthesize delegate;

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
	if(self.parser.delegate)
		[self.delegate midiSource:self midiReceived:pktlist];
}

static
void PGMIDIReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon)
{
    PGMidiSource *self = (__bridge PGMidiSource *)srcConnRefCon;
    [self midiRead:pktlist];
}

@end

//==============================================================================

@implementation PGMidiDestination

- (id) initWithMidi:(PGMidi*)m endpoint:(MIDIEndpointRef)e
{
    if ((self = [super initWithMidi:m endpoint:e]))
    {
        _midi     = m;
        _endpoint = e;
    }
    return self;
}

- (void)sendNoteOn:(MidiNoteOn *)noteOn
{
	uint8_t bytes[3];
	bytes[0] = 0x90 | (noteOn.channel & 0x0F);
	bytes[1] = noteOn.note;
	bytes[2] = noteOn.velocity;
	[self sendBytes:bytes size:3];
}

- (void)sendControlChange:(MidiControlChange *)cc
{
	uint8_t bytes[3];
	bytes[0] = 0xB0 | (cc.channel & 0x0F);
	bytes[1] = cc.parameter;
	bytes[2] = cc.ccValue;
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
	//DLog(@"sysex send %@", request->complete ? @"succeeded" : @"failed");
	free(request);
}

- (void) sendSysexBytes:(const UInt8*)bytes size:(UInt32)size
{
	//DLog(@"sending %ld sysex bytes to %@", size, self.name);
	assert(size < 65536);
	
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

@end

//==============================================================================

@implementation PGMidi

@synthesize delegate;
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
    [delegate midiSourceAdded:source];

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
        [delegate midiSourceRemoved:source];
        [sources removeObject:source];
    }
}

- (void) connectDestination:(MIDIEndpointRef)endpoint
{
    //[delegate midiInput:self event:@"Added a destination"];
    PGMidiDestination *destination = [[PGMidiDestination alloc] initWithMidi:self endpoint:endpoint];
    [destinations addObject:destination];
    [delegate midiDestinationAdded:destination];
}

- (void) disconnectDestination:(MIDIEndpointRef)endpoint
{
    //[delegate midiInput:self event:@"Removed a device"];

    PGMidiDestination *destination = [self getDestination:endpoint];

    if (destination)
    {
        [delegate midiDestinationRemoved:destination];
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
