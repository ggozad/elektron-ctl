//
//  A4Kit.h
//  A4Sysex
//
//  Created by Jakob Penca on 3/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4SysexMessage.h"
#import "A4Sound.h"

#define A4PerformanceMacroCount 10

typedef struct A4PerformanceMacro
{
	char name[16];
	A4ModTarget targets[5];
	uint8_t value;
	uint8_t bipolar;
}
A4PerformanceMacro;


typedef enum A4PolyAllocationMode
{
	A4PolyAllocationModeReset,
	A4PolyAllocationModeRotate,
	A4PolyAllocationModeReassign,
	A4PolyAllocationModeUnison
}
A4PolyAllocationMode;

typedef struct A4PolySettings
{
	uint8_t activeVoices;
	uint8_t allocationMode;
	uint8_t useTrackSounds;
	uint8_t unisonDetuneAmount;
	uint8_t unisonPanSpreadAmount;
}
A4PolySettings;

@interface A4Kit : A4SysexMessage

@property (strong, nonatomic) NSString *name;
@property (nonatomic) A4PerformanceMacro *macros;
@property (nonatomic) A4PolySettings *polyphony;

+ (instancetype)defaultKit;
- (BOOL) isDefaultKit;
- (BOOL) isEqualToKit:(A4Kit *)kit;
- (A4Sound *)soundAtTrack:(uint8_t)track copy:(BOOL)copy;
- (A4Sound *)copySound:(A4Sound *)sound toTrack:(uint8_t)track;
- (void) copyFXSettingsFromKit:(A4Kit *)kit;
- (void) setFxParamValue:(A4PVal)value;
- (A4PVal) valueForFxParam:(A4Param)param;
- (uint8_t) levelForTrack:(uint8_t)t;
- (void) setLevel:(uint8_t)level forTrack:(uint8_t)t;


@end
