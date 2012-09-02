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

@interface MDMachinedrumGlobalSettings : NSObject
@property uint8_t originalPosition;
@property uint8_t midiBaseChannel;
@property MDMachinedrumGlobalSettings_MechanicalSettings mechanicalSettings;
@property MDMachinedrumGlobalSettings_RoutingOutput routing;
@property float tempo;
- (void) setTempoFromLowByte:(uint8_t)low highByte:(uint8_t)hi;
- (NSData *) tempoBytes;
@end