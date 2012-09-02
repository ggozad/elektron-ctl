//
//  MDMachinedrumGlobalSettings.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 8/30/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MDMachinedrumGlobalSettings_RoutingOutput
{
	MDMachinedrumGlobalSettings_OutputRouting_Individual_1,
	MDMachinedrumGlobalSettings_OutputRouting_Individual_2,
	MDMachinedrumGlobalSettings_OutputRouting_Individual_3,
	MDMachinedrumGlobalSettings_OutputRouting_Individual_4,
	MDMachinedrumGlobalSettings_OutputRouting_Individual_5,
	MDMachinedrumGlobalSettings_OutputRouting_Stereo_Out,
}
MDMachinedrumGlobalSettings_RoutingOutput;

typedef enum MDMachinedrumGlobalSettings_MechanicalSettings
{
	MDMachinedrumGlobalSettings_MechanicalSettings_24ppr,
	MDMachinedrumGlobalSettings_MechanicalSettings_32ppr,
	MDMachinedrumGlobalSettings_MechanicalSettings_Reserved_2,
	MDMachinedrumGlobalSettings_MechanicalSettings_Reserved_3
}
MDMachinedrumGlobalSettings_MechanicalSettings;

typedef enum MDMachinedrumGlobalSettings_ExtendedMode
{
	MDMachinedrumGlobalSettings_ExtendedMode_Off,
	MDMachinedrumGlobalSettings_ExtendedMode_On
}
MDMachinedrumGlobalSettings_ExtendedMode;

typedef struct MDMachinedrumGlobalSettings_ExternalTrigSettings
{
	uint8_t track;
	uint8_t gate;
	uint8_t sense;
	uint8_t minLevel;
	uint8_t maxLevel;
}
MDMachinedrumGlobalSettings_ExternalTrigSettings;

typedef enum MDMachinedrumGlobalSettings_ProgramChangeSettings
{
	MDMachinedrumGlobalSettings_ProgramChangeSettings_In,
	MDMachinedrumGlobalSettings_ProgramChangeSettings_Out,
	MDMachinedrumGlobalSettings_ProgramChangeSettings_InOut
}
MDMachinedrumGlobalSettings_ProgramChangeSettings;

typedef enum MDMachinedrumGlobalSettings_TrigMode
{
	MDMachinedrumGlobalSettings_TrigMode_Gate,
	MDMachinedrumGlobalSettings_TrigMode_Start,
	MDMachinedrumGlobalSettings_TrigMode_Queue
}
MDMachinedrumGlobalSettings_TrigMode;

@interface MDMachinedrumGlobalSettings : NSObject
@property uint8_t originalPosition;
@property uint8_t midiBaseChannel;
@property MDMachinedrumGlobalSettings_MechanicalSettings mechanicalSettings;
@property MDMachinedrumGlobalSettings_RoutingOutput routing;
@property float tempo;
@property MDMachinedrumGlobalSettings_ExtendedMode extendedMode;
@property uint8_t *keyMapStructure;
@property BOOL clockIn;
@property BOOL clockOut;
@property BOOL transportIn;
@property BOOL transportOut;
@property BOOL localControl;
@property MDMachinedrumGlobalSettings_ExternalTrigSettings trigSettingsLeft;
@property MDMachinedrumGlobalSettings_ExternalTrigSettings trigSettingsRight;
@property MDMachinedrumGlobalSettings_ProgramChangeSettings programChangeSettings;
@property MDMachinedrumGlobalSettings_TrigMode programChangeTrigMode;

+ (id) globalSettingsWithData:(NSData *)d;
- (id) sysexData;
- (void) setTempoFromLowByte:(uint8_t)low highByte:(uint8_t)hi;
- (NSData *) tempoBytes;
@end
