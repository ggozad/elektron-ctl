//
//  PGMidi.h
//  PGMidi
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

@class PGMidi;
@class PGMidiSource;
@class PGMidiDestination;
@class MidiInputParser;
@class MidiControlChange;
@class MidiNoteOn;

/// Delegate protocol for PGMidi class.
///
/// @see PGMidi
@protocol PGMidiDelegate
- (void) midiSourceAdded:(PGMidiSource *)source;
- (void) midiSourceRemoved:(PGMidiSource *)source;
- (void) midiDestinationAdded:(PGMidiDestination *)destination;
- (void) midiDestinationRemoved:(PGMidiDestination *)destination;
@end

/// Class for receiving MIDI input from any MIDI device.
///
/// If you intend your app to support iOS 3.x which does not have CoreMIDI
/// support, weak link to the CoreMIDI framework, and only create a
/// PGMidi object if you are running the right version of iOS.
///
/// @see PGMidiDelegate
@interface PGMidi : NSObject
{
    MIDIClientRef      client;
    MIDIPortRef        outputPort;
    MIDIPortRef        inputPort;
    id<PGMidiDelegate> delegate;
    NSMutableArray    *sources, *destinations;
}

@property (nonatomic,strong) id<PGMidiDelegate> delegate;


@property (nonatomic,readonly) NSUInteger         numberOfConnections;
@property (nonatomic,readonly) NSMutableArray    *sources;
@property (nonatomic,readonly) NSMutableArray    *destinations;


+ (PGMidi *) sharedInstance;

- (void) sendBytes:(const UInt8*)bytes size:(UInt32)size;
- (void) sendPacketList:(const MIDIPacketList *)packetList;

#if TARGET_OS_IPHONE
- (void) enableNetwork:(BOOL)enabled;
#endif

@end



/// Represents a source/destination for MIDI data
///
/// @see PGMidiSource
/// @see PGMidiDestination
@interface PGMidiConnection : NSObject
{
    PGMidi                  *_midi;
    MIDIEndpointRef          _endpoint;
    NSString                *_name;
#if TARGET_OS_IPHONE
	BOOL					_isNetworkSession;
#endif
}
@property (nonatomic,readonly) PGMidi          *midi;
@property (nonatomic,readonly) MIDIEndpointRef  endpoint;
@property (nonatomic,readonly) NSString        *name;

#if TARGET_OS_IPHONE
@property (nonatomic,readonly) BOOL             isNetworkSession;
#endif
@end


/// Delegate protocol for PGMidiSource class.
/// Adopt this protocol in your object to receive MIDI events
///
/// IMPORTANT NOTE:
/// MIDI input is received from a high priority background thread
///
/// @see PGMidiSource
@protocol PGMidiSourceDelegate

// Raised on main run loop
/// NOTE: Raised on high-priority background thread.
///
/// To do anything UI-ish, you must forward the event to the main runloop
/// (e.g. use performSelectorOnMainThread:withObject:waitUntilDone:)
///
/// Be careful about autoreleasing objects here - there is no NSAutoReleasePool.
///
/// Handle the data like this:
///
///     // for some function HandlePacketData(Byte *data, UInt16 length)
///     const MIDIPacket *packet = &packetList->packet[0];
///     for (int i = 0; i < packetList->numPackets; ++i)
///     {
///         HandlePacketData(packet->data, packet->length);
///         packet = MIDIPacketNext(packet);
///     }
- (void) midiSource:(PGMidiSource*)input midiReceived:(const MIDIPacketList *)packetList;

@end

/// Represents a source of MIDI data identified by CoreMIDI
///
/// @see PGMidiSourceDelegate
@interface PGMidiSource : PGMidiConnection
{
    id<PGMidiSourceDelegate> delegate;
}
@property (nonatomic, strong) MidiInputParser *parser;
@property (nonatomic, strong) id<PGMidiSourceDelegate> delegate;
@end

//==============================================================================

/// Represents a destination for MIDI data identified by CoreMIDI
@interface PGMidiDestination : PGMidiConnection
{
}
- (void) sendNoteOn:(MidiNoteOn *)noteOn;
- (void) sendControlChange:(MidiControlChange *)cc;
- (void) sendBytes:(const UInt8*)bytes size:(UInt32)size;
- (void) sendPacketList:(const MIDIPacketList *)packetList;
- (void) sendSysexBytes:(const UInt8*)bytes size:(UInt32)size;
- (void) sendSysexData:(NSData *)d;
@end

//==============================================================================

