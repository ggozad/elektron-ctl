//
//  WaveEditor.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 3/18/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "WaveEditor.h"
#import "NPair.h"

@implementation WaveEditor

+ (id)waveEditorWithFileAtPath:(NSString *)path
{
	WaveEditor *editor = [WaveEditor new];
	editor.path = path;
	editor.data = [editor audioDataForFileAtPath:path];
	editor.asbd = [editor asbdForFileAtPath:path];
	return editor;
}

- (void)trimAudioWithStartSample:(NSUInteger)start endSample:(NSUInteger)endSample
{
	AudioStreamBasicDescription asbd = self.asbd;
	NSUInteger startIndex = start * asbd.mBytesPerFrame;
	NSUInteger endIndex = endSample * asbd.mBytesPerFrame;
	
	if(endIndex <= startIndex || endIndex >= self.data.length) return;
	self.data = [self.data subdataWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
}

- (void) writeAudioData
{
	AudioStreamBasicDescription asbd = self.asbd;
	AudioFileID fileID = NULL;
	NSURL *url = [NSURL fileURLWithPath:self.path];
	OSStatus err = AudioFileCreateWithURL((__bridge CFURLRef)url, kAudioFileWAVEType, &asbd, kAudioFileFlags_EraseFile | kAudioFileFlags_DontPageAlignAudioData, &fileID);
	
	if(err)
	{
		DLog(@"failed to create file with err: %d at url: %@", err, url);
		return;
	}
	
	UInt32 numBytes = self.data.length;
	err = AudioFileWriteBytes(fileID, FALSE, 0, &numBytes, self.data.bytes);
	if(err)
	{
		DLog(@"failed to write bytes..");
		return;
	}
	
	AudioFileClose(fileID);
	if(err)
	{
		DLog(@"failed to close file..");
		return;
	}
}

- (AudioStreamBasicDescription)asbdForFileAtPath:(NSString *)path
{
	AudioStreamBasicDescription asbd = {};
	
	ExtAudioFileRef fileRef = NULL;
	OSStatus err = ExtAudioFileOpenURL((__bridge CFURLRef)([NSURL URLWithString:path]), &fileRef);
	if(err != noErr)
	{
		DLog(@"fail open file: %d", err);
		return asbd;
	}
	
	UInt32 size = sizeof(AudioStreamBasicDescription);
	err = ExtAudioFileGetProperty(fileRef, kExtAudioFileProperty_FileDataFormat, &size, &asbd);
	if(err != noErr)
	{
		DLog(@"fail getting asbd: %d", err);
		return asbd;
	}
	
	[[self class] printASBD:asbd];
	return asbd;
}

- (NSData *) audioDataForFileAtPath:(NSString *)path
{
	uint16_t numChannels = 0;	
	uint32_t audioByteSize = 0;
	uint32_t sampleRate = 0;
	uint16_t bitsPerSample = 0;
	uint16_t bytesPerSample = 0;
	NSUInteger numSamples = 0;
	
	ExtAudioFileRef fileRef = NULL;
	NSURL *url = [NSURL fileURLWithPath:path];
	OSStatus err = ExtAudioFileOpenURL((__bridge CFURLRef)url, &fileRef);
	
	if(err != noErr)
	{
		DLog(@"fail open file: %d", err);
		return nil;
	}
	
	AudioStreamBasicDescription asbd = {};
	UInt32 size = sizeof(AudioStreamBasicDescription);
	err = ExtAudioFileGetProperty(fileRef, kExtAudioFileProperty_FileDataFormat, &size, &asbd);
	if(err != noErr)
	{
		DLog(@"fail getting asbd: %d", err);
		return nil;
	}
	
	[[self class] printASBD:asbd];
	
	
	numChannels = asbd.mChannelsPerFrame;
	if(numChannels != 1)
	{
		DLog(@"unsupported channel count: %d", numChannels);
		return nil;
	}
	
	bitsPerSample = asbd.mBitsPerChannel;
	bytesPerSample = asbd.mBytesPerFrame;
	sampleRate = asbd.mSampleRate;
	
	SInt64 numFrames = 0;
	UInt32 sint64size = sizeof(SInt64);
	err = ExtAudioFileGetProperty(fileRef, kExtAudioFileProperty_FileLengthFrames, &sint64size, &numFrames);
	if(err != noErr)
	{
		DLog(@"failed to get num frames property: %d", err);
		return nil;
	}
	numSamples = numFrames;
	audioByteSize = numSamples * bytesPerSample;
	
	unsigned char *rawAudioBytes = malloc(audioByteSize);
	
	AudioBuffer buffer =
	{
		.mNumberChannels = 1,
		.mDataByteSize = audioByteSize,
		.mData = rawAudioBytes
	};
	
	AudioBufferList bufferList;
	bufferList.mNumberBuffers = 1;
	bufferList.mBuffers[0] = buffer;
	
	UInt32 ioFrames = numSamples;
	err = ExtAudioFileRead(fileRef, &ioFrames, &bufferList);
	if(err != noErr)
	{
		DLog(@"fail reading audio bytes: %d", err);
		return nil;
	}
	
	DLog(@"read %d frames - should be %ld. bytes: %d", ioFrames, numSamples, audioByteSize);
	err = ExtAudioFileDispose(fileRef);
	
	
	NSData *rawAudioData = [NSData dataWithBytesNoCopy:rawAudioBytes length:audioByteSize freeWhenDone:YES];
	
	DLog(@"wav input:\n\n\tsamplerate: %d\n\tbytesize: %d(%ld)\n\tnumSamples: %ld\n\tbitspersample: %d\n\tbytespersample: %d\n\n", sampleRate, audioByteSize, rawAudioData.length, numSamples, bitsPerSample, bytesPerSample);
	
	return rawAudioData;
}

- (NSArray *) zeroCrossingsForAudioData:(NSData *)d minDist:(NSUInteger)minDist direction:(WaveEditorZeroCrossingDirection) dir
{
	NSMutableArray *array = [NSMutableArray array];
	
	const SInt16 *samples = d.bytes;
	const UInt32 numSamples = d.length / 2;
	
	SInt16 lastSample = samples[0];
	
	for (int i = 0; i < numSamples; i++)
	{
		SInt16 sample = samples[i];
		
		if((dir == WaveEditorZeroCrossingDirectionUp && (lastSample < 0 && sample >= 0 && sample - lastSample >= minDist)) ||
		   (dir == WaveEditorZeroCrossingDirectionDown && (lastSample >= 0 && sample < 0 && lastSample - sample >= minDist)) ||
		   (dir == WaveEditorZeroCrossingDirectionAny && ((lastSample >= 0 && sample < 0 && lastSample - sample >= minDist) ||
														  (lastSample < 0 && sample >= 0 && sample - lastSample >= minDist))))
		{
			NSNumber *num = [NSNumber numberWithInt:i];
			[array addObject:num];
		}
		lastSample = sample;
	}
	return array;
}


+ (void) printASBD: (AudioStreamBasicDescription) asbd
{	
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
	
    NSLog (@"  Sample Rate:         %10.0f",  asbd.mSampleRate);
    NSLog (@"  Format ID:           %10s",    formatIDString);
    NSLog (@"  Format Flags:        %10X",    asbd.mFormatFlags);
    NSLog (@"  Bytes per Packet:    %10d",    asbd.mBytesPerPacket);
    NSLog (@"  Frames per Packet:   %10d",    asbd.mFramesPerPacket);
    NSLog (@"  Bytes per Frame:     %10d",    asbd.mBytesPerFrame);
    NSLog (@"  Channels per Frame:  %10d",    asbd.mChannelsPerFrame);
    NSLog (@"  Bits per Channel:    %10d",    asbd.mBitsPerChannel);
}


@end
