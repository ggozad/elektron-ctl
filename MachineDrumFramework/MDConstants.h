//
//  MDConstants.h
//  MachineDrumFrameworkOSX
//
//  Created by Jakob Penca on 6/22/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#ifndef MachineDrumFrameworkOSX_MDConstants_h
#define MachineDrumFrameworkOSX_MDConstants_h

#define kMDSysexStatusResponseNotification @"kMDSysexStatusResponseNotification"
#define kMDSysexPatternDumpNotification @"kMDSysexPatternDumpNotification"
#define kMDSysexKitDumpNotification @"kMDSysexKitDumpNotification"
#define kMDSysexGlobalSettingsDumpNotification @"kMDSysexGlobalSettingsDumpNotification"
#define kMIDIFoundationReadyChange @"kMIDIFoundationReadyChange"

#define kMDturboMIDISpeedRequest @"kMDturboMIDISpeedRequest"
#define kMDturboMIDISpeedAnswer @"kMDturboMIDISpeedRequestAnswer"
#define kMDturboMIDISpeedNegotiation @"kMDturboMIDISpeedNegotiation"
#define kMDturboMIDISpeedAcknowledgement @"kMDturboMIDISpeedAcknowledgement"
#define kMDturboMIDISpeedTest @"kMDturboMIDISpeedTest"
#define kMDturboMIDISpeedTestResult @"kMDturboMIDISpeedTestResult"

#define kMDSysexSDSdumpHeaderNotification @"kMDSysexSDSdumpHeaderNotification"
#define kMDSysexSDSdumpRequestNotification @"kMDSysexSDSdumpRequestNotification"
#define kMDSysexSDSdumpPacketNotification @"kMDSysexSDSdumpPacketNotification"
#define kMDSysexSDSdumpACKNotification @"kMDSysexSDSdumpACKNotification"
#define kMDSysexSDSdumpNAKNotification @"kMDSysexSDSdumpNAKNotification"
#define kMDSysexSDSdumpCANCELNotification @"kMDSysexSDSdumpCANCELNotification"
#define kMDSysexSDSdumpWAITNotification @"kMDSysexSDSdumpWAITNotification"

#define kMDSysexSetSampleNameNotification @"kMDSysexSetSampleNameNotification"

#define kMDDataDumpDidWriteFileNotification @"kMDDataDumpDidWriteFileNotification"
#define kMDSDSDidWriteAudioFileNotification @"kMDSDSDidWriteAudioFileNotification"
#define kMDSDSDidWriteSyxFileNotification @"kMDSDSDidWriteSyxFileNotification"

typedef enum MDPatternTrigState
{
	trigStateOff,
	trigStateOn,
	trigStateLocked
}
MDPatternTrigState;


#endif
