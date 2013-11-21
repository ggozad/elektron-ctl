//
//  A4PolyMapper.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 7/10/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MidiInputParser.h"
#import "PGMidi.h"

typedef enum A4PolyMapperMappingMode
{
	A4PolyMapperMappingModeThru,
	A4PolyMapperMappingModePoly,
	A4PolyMapperMappingModeUnison
}
A4PolyMapperMappingMode;

@protocol A4PolyMapperDelegate <NSObject>
- (void) polyMapperDidSendNoteOn:(MidiNoteOn)noteOn;
- (void) polyMapperDidSendNoteOff:(MidiNoteOff)noteOff;
@end

@interface A4PolyMapper : NSObject  <MidiInputDelegate, PGMidiDelegate>
@property (nonatomic) A4PolyMapperMappingMode mode;
@property (strong, nonatomic) NSArray *channels;
@property (assign, nonatomic) id<A4PolyMapperDelegate> delegate;
@property BOOL ccMirroringEnabled;

+ (instancetype) sharedInstance;
- (void) clearAllHeldNotes;
@end
