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
#define kMDSysexSongDumpNotification @"kMDSysexSongDumpNotification"
#define kMDSysexKitDumpNotification @"kMDSysexKitDumpNotification"
#define kMDSysexGlobalSettingsDumpNotification @"kMDSysexGlobalSettingsDumpNotification"
#define kMIDIFoundationReadyChange @"kMIDIFoundationReadyChange"

#define kA4SysexNotification @"kA4SysexNotification"

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

#define kMDSoftMIDIThruMasterOrSlaveKey @"kMDSoftMIDIThruMasterOrSlaveKey"
#define kMDSoftMIDIThruClockEnabledKey @"kMDSoftMIDIThruClockEnabledKey"
#define kMDSoftMIDIThruStartStopEnabledKey @"kMDSoftMIDIThruStartStopEnabledKey"

typedef enum MDPatternTrigState
{
	trigStateOff,
	trigStateOn,
	trigStateLocked
}
MDPatternTrigState;

#define MD_MIDI_STATUS_ANY				(0x80)

#define MD_MIDI_STATUS_SYSEX_BEGIN		(0xF0)
#define MD_MIDI_STATUS_SYSEX_END		(0xF7)

#define MD_MIDI_STATUS_NOTE_OFF			(0x80)
#define MD_MIDI_STATUS_NOTE_ON			(0x90)
#define MD_MIDI_STATUS_AFTERTOUCH		(0xA0)
#define MD_MIDI_STATUS_CONTROL_CHANGE	(0xB0)
#define MD_MIDI_STATUS_PROGRAM_CHANGE	(0xC0)
#define MD_MIDI_STATUS_CHANNEL_PRESSURE	(0xD0)
#define MD_MIDI_STATUS_PITCH_WHEEL		(0xE0)

#define MD_MIDI_RT_CLOCK				(0xF8)
#define MD_MIDI_RT_TICK					(0xF9)
#define MD_MIDI_RT_START				(0xFA)
#define MD_MIDI_RT_CONTINUE				(0xFB)
#define MD_MIDI_RT_STOP					(0xFC)
#define MD_MIDI_RT_ACTIVESENSE			(0xFE)
#define MD_MIDI_RT_RESET				(0xFF)

#endif
