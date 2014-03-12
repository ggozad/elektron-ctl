//
//  A4Sound.h
//  A4Sysex
//
//  Created by Jakob Penca on 3/31/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4SysexMessage.h"
#import "A4Params.h"
#import "A4PVal.h"

typedef UInt32 A4SoundTagBitmask;

typedef enum A4SoundTag
{
	A4SoundTagBass		= 0x0001 << 0,
	A4SoundTagLead		= 0x0001 << 1,
	A4SoundTagPad		= 0x0001 << 2,
	A4SoundTagTexture	= 0x0001 << 3,
	A4SoundTagChord		= 0x0001 << 4,
	A4SoundTagKeys		= 0x0001 << 5,
	A4SoundTagBrass		= 0x0001 << 6,
	A4SoundTagStrings	= 0x0001 << 7,
	A4SoundTagTransien	= 0x0001 << 8,
	A4SoundTagSoundFX	= 0x0001 << 9,
	A4SoundTagKick		= 0x0001 << 10,
	A4SoundTagSnare		= 0x0001 << 11,
	A4SoundTagHihat		= 0x0001 << 12,
	A4SoundTagPercussi	= 0x0001 << 13,
	A4SoundTagAtmosphe	= 0x0001 << 14,
	A4SoundTagEvolving	= 0x0001 << 15,
	A4SoundTagNoisy		= 0x0001 << 16,
	A4SoundTagGlitch	= 0x0001 << 17,
	A4SoundTagHard		= 0x0001 << 18,
	A4SoundTagSoft		= 0x0001 << 19,
	A4SoundTagExpressi	= 0x0001 << 20,
	A4SoundTagDeep		= 0x0001 << 21,
	A4SoundTagDark		= 0x0001 << 22,
	A4SoundTagBright	= 0x0001 << 23,
	A4SoundTagVintage	= 0x0001 << 24,
	A4SoundTagAcid		= 0x0001 << 25,
	A4SoundTagEpic		= 0x0001 << 26,
	A4SoundTagFail		= 0x0001 << 27,
	A4SoundTagTempoSy	= 0x0001 << 28,
	A4SoundTagInput		= 0x0001 << 29,
	A4SoundTagMine		= 0x0001 << 30,
	A4SoundTagFavourit	= 0x0001 << 31,
}
A4SoundTags;

typedef enum A4SoundSettingPortamento
{
	A4SoundSettingPortamentoOff,
	A4SoundSettingPortamentoOn,
	A4SoundSettingPortamentoLegato,
}
A4SoundSettingPortamento;

typedef enum A4SoundSettingLegato
{
	A4SoundSettingLegatoOff,
	A4SoundSettingLegatoOn
}
A4SoundSettingLegato;

typedef enum A4SoundSettingOscillatorDrift
{
	A4SoundSettingOscillatorDriftOff,
	A4SoundSettingOscillatorDriftOn
}
A4SoundSettingOscillatorDrift;

typedef enum A4SoundSettingVelocity
{
	A4SoundSettingVelocityOff,
	A4SoundSettingVelocityLogarithmic,
	A4SoundSettingVelocityLinear,
	A4SoundSettingVelocityExponential
}
A4SoundSettingVelocity;

typedef enum A4SoundModulatorType
{
	A4SoundModulatorTypeVelocity,
	A4SoundModulatorTypePitchBend,
	A4SoundModulatorTypeModWheel,
	A4SoundModulatorTypeBreath,
	A4SoundModulatorTypeAftertouch,
}
A4SoundModulatorType;

typedef struct A4ModTarget
{
	int8_t coarse;
	uint8_t fine;
	uint8_t track;
	A4Param param;
}
A4ModTarget;

typedef struct A4ModBipolar
{
	A4ModTarget targets[5];
	uint8_t reserved;
	uint8_t bipolar;
}
A4ModBipolar;

typedef struct A4Mod
{
	A4ModTarget targets[5];
}
A4Mod;

typedef struct A4SoundParams
{
	int16_t param[A4ParamLayoutCount];
}
A4SoundParams;

typedef struct A4SoundModTargets
{
	A4ModBipolar velocity;
	A4Mod pitchbend;
	A4Mod modwheel;
	A4Mod breath;
	A4Mod aftertouch;
}
A4SoundModTargets;

typedef struct A4SoundSettings
{
	uint8_t oscillatorDrift;
	uint8_t portamento;
	uint8_t legatoMode;
	uint8_t velocityMode;
	uint8_t filterBoost;
	uint8_t reserved[3];
	A4SoundModTargets modulations;
}
A4SoundSettings;

@interface A4Sound : A4SysexMessage
@property (copy, nonatomic) NSString *name;
@property (nonatomic) A4SoundTagBitmask tags;
@property (nonatomic) A4SoundParams *params;
@property (nonatomic) A4SoundSettings *settings;

+ (instancetype)defaultSound;
- (BOOL) isDefaultSound;
- (BOOL) isEqualToSound:(A4Sound *)sound;
- (void) setParamValue:(A4PVal)value;
- (A4PVal) valueForParam:(A4Param)param;
- (void) addTag:(A4SoundTags)tag;
- (void) removeTag:(A4SoundTags)tag;
- (BOOL) tagMatchesAnyTag:(A4SoundTags)tag;

@end
