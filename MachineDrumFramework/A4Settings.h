//
//  A4Settings.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4SysexMessage.h"

typedef enum A4SettingsPatternChangeMode
{
	A4SettingsPatternChangeModeSequential,
	A4SettingsPatternChangeModeDirectStart,
	A4SettingsPatternChangeModeDirectJump
}
A4SettingsPatternChangeMode;

typedef enum A4SettingsSequencerMode
{
	A4SettingsSequencerModePattern,
	A4SettingsSequencerModeChain,
	A4SettingsSequencerModeSong
}
A4SettingsSequencerMode;

typedef enum A4SettingsParamPage
{
	A4SettingsParamPagePerformance,
	A4SettingsParamPageArpeggiator,
	A4SettingsParamPageNotes,
	A4SettingsParamPageOscillator1,
	A4SettingsParamPageOscillator2,
	A4SettingsParamPageFilters,
	A4SettingsParamPageAmplifier,
	A4SettingsParamPageEnvelopes,
	A4SettingsParamPageLFOs,
}
A4SettingsParamPage;


@interface A4Settings : A4SysexMessage
- (BOOL) isTrackMuted:(uint8_t) track;
- (void) setTrack:(uint8_t) track muted:(BOOL)muted;
@property (nonatomic) uint8_t muteMask;
@property (nonatomic) int8_t transpose;
@property (nonatomic) int8_t multimapOctave;
@property (nonatomic) uint8_t patternPage;
@property (nonatomic) uint8_t selectedTrackParams, selectedTrackTrack, selectedTrack;
@property (nonatomic) double bpm;
@property (nonatomic) A4SettingsParamPage paramPage;
@property (nonatomic) A4SettingsPatternChangeMode patternChangeMode;
@property (nonatomic) A4SettingsSequencerMode sequencerMode;
@end
