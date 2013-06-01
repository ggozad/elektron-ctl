//
//  BufferPlayer.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 3/20/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "BufferPlayer.h"
#import "MyUtils.m"

typedef struct Controller
{
	AudioUnit	outputUnit;
	SInt16		*bytes;
	NSUInteger	numFrames;
	NSUInteger	loopStartInclusive;
	NSUInteger	loopEndInclusive;
	NSUInteger	index;
	BOOL		reachedDecayPoint;
}
Controller;

OSStatus Render
(
 void						*inRefCon,
 AudioUnitRenderActionFlags *flags,
 const AudioTimeStamp		*timeStamp,
 UInt32						inBusNumber,
 UInt32						inNumberFrames,
 AudioBufferList			*ioData
)
{
	
	Controller *c = (Controller *) inRefCon;
	const SInt16 *bytes = c->bytes;
	
	SInt16 *buffer = (SInt16 *)ioData->mBuffers[0].mData;
	
	for (int i = 0; i < inNumberFrames; i++)
	{
//		buffer[i] = bytes[c->index] & 0xFFF0;
		buffer[i] = bytes[c->index];
		c->index++;
		
		if(c->index > c->loopEndInclusive || c->index >= c->numFrames)
			c->index = c->loopStartInclusive;
	}
	
	return noErr;
}


void CreateAndConnectOutputUnit(Controller *controller)
{
	AudioComponentDescription out = {0};
	out.componentType = kAudioUnitType_Output;
	out.componentSubType = kAudioUnitSubType_GenericOutput;
	out.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	AudioComponent comp = AudioComponentFindNext(NULL, &out);
	
	if(comp == NULL)
	{
		DLog(@"can't find component...");
		return;
	}
	CheckError(AudioComponentInstanceNew(comp, &controller->outputUnit), "failed to instantiate the output audio unit");
}

@interface BufferPlayer()
{
	Controller _controller;
	//NSData *_audioData;
}
@end

@implementation BufferPlayer

- (id)init
{
	if(self = [super init])
	{
		//[self setup];
	}
	return self;
}

- (void) stop
{
	CheckError(AudioOutputUnitStop(_controller.outputUnit), "stop fail");
}

- (void)start
{
	if(!self.audioData)
	{
		DLog(@"no audio data");
		return;
	}
	
	CheckError(AudioOutputUnitStart(_controller.outputUnit), "start fail");
	
	NSUInteger numFrames = self.audioData.length / self.asbd.mChannelsPerFrame;
	
	_controller.index = 0;
	_controller.loopStartInclusive = 0;
	_controller.loopEndInclusive = numFrames - 1;
	DLog(@"play...");
}

- (void)bang
{
	_controller.index = 0;
}

- (void)setLoopStart:(NSUInteger)s end:(NSUInteger)e
{
	_controller.loopStartInclusive = s;
	_controller.loopEndInclusive = e;
}

- (void)setAudioData:(NSData *)audioData asbd:(AudioStreamBasicDescription) asbd
{
	DLog(@"data bytes: %d", audioData.length);
	
	self.audioData = [audioData copy];
	self.asbd = asbd;
	
	/*
	CheckError(AudioUnitSetProperty(_controller.outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &asbd, sizeof(asbd)), "failed to set out unit input stream format");
	*/
	
	//[self dispose];
	
	
	_controller.bytes = (SInt16 *)audioData.bytes;
	_controller.numFrames = audioData.length / asbd.mChannelsPerFrame;
	_controller.index = 0;
	
	[self setup];
}

- (void) setup
{
	CreateAndConnectOutputUnit(&_controller);
	
	/*
	AudioStreamBasicDescription asbd = {0};
    
    asbd.mFormatID          = kAudioFormatLinearPCM;
    asbd.mFormatFlags       = kAudioFormatFlagIsSignedInteger;
    asbd.mBytesPerPacket    = 2;
    asbd.mFramesPerPacket   = 1;
    asbd.mBytesPerFrame     = 2;
    asbd.mChannelsPerFrame  = 1;
    asbd.mBitsPerChannel    = 16;
    asbd.mSampleRate        = 44100;
	 */
	
	AudioStreamBasicDescription asbd = self.asbd;
	
	CheckError(AudioUnitSetProperty(_controller.outputUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &asbd, sizeof(asbd)), "failed to set out unit input stream format");
	
	AURenderCallbackStruct input;
	input.inputProc = Render;
	input.inputProcRefCon = &_controller;
	
	CheckError(AudioUnitSetProperty(_controller.outputUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &input, sizeof(input)), "failed to set the render callback");
	
	CheckError(AudioUnitInitialize(_controller.outputUnit), "failed to initialize the output unit");
	
	
	
}

- (void)dealloc
{
	[self dispose];
}

- (void) dispose
{
	[self stop];
	AudioUnitUninitialize(_controller.outputUnit);
	AudioComponentInstanceDispose(_controller.outputUnit);
	DLog(@"disposing...");
}

@end
