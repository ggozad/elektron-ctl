//
//  MyUtils.c
//  04 Audio Queue Recorder
//
//  Created by Jakob Penca on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#pragma mark - Utility Functions

static void CheckError(OSStatus err, const char *operation)
{
    if(err == noErr) return;
    
    char errorString[20];
    *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(err);
    if (isprint(errorString[1]) && isprint(errorString[2]) && 
        isprint(errorString[3]) && isprint(errorString[4])) 
    {
        errorString[0] = errorString[5] = '\'';
        errorString[6] = '\0';
    }
    else
    {
        sprintf(errorString, "%d", (int)err);
    }
    
    fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
    exit(1);
}

static int MyComputeRecordBufferByteSize(const AudioStreamBasicDescription *format, AudioQueueRef queueRef, float seconds)
{
    int packets = 0;
	int frames, bytes = 0;
    
    frames = (int)ceil(seconds * format->mSampleRate);
    
    if(format->mBytesPerFrame > 0)
    {
        bytes = frames * format->mBytesPerFrame;
    }
    else
    {
        UInt32 maxPacketSize;
        if(format->mBytesPerPacket > 0) 
            maxPacketSize = format->mBytesPerPacket;
        else
        {
            UInt32 propertySize = sizeof(maxPacketSize);
            CheckError(AudioQueueGetProperty(queueRef, kAudioConverterPropertyMaximumOutputPacketSize, &maxPacketSize, &propertySize), "Couldn't determine maximum packet size");
            if(format->mFramesPerPacket > 0)
                packets = frames / format->mFramesPerPacket;
            else
                packets = frames;
            
            
        }
        
        if(packets == 0) packets = 1;
        bytes = packets * maxPacketSize;
    }
    
    printf("buf byte size: %d\n", bytes);
    return bytes;
}

static void CalculateBytesForTime(AudioFileID                  inAudioFile, 
                           AudioStreamBasicDescription  inDesc, 
                           Float64                      inSeconds, 
                           UInt32                       *outBufferSize, 
                           UInt32                       *outNumPackets
                           )
{
    UInt32 maxPacketSize;
    UInt32 propSize = sizeof(maxPacketSize);
    CheckError(AudioFileGetProperty(inAudioFile, kAudioFilePropertyPacketSizeUpperBound, &propSize, &maxPacketSize), "failed to get max packet size");
    
    static const int maxBufferSize = 0x10000;
    static const int minBufferSize = 0x4000;
    
    if(inDesc.mFramesPerPacket)
    {
        Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
        *outBufferSize = numPacketsForTime * maxPacketSize;
    }
    else
    {
        *outBufferSize = maxBufferSize > maxPacketSize ? maxBufferSize : maxPacketSize;
    }
    
    if(*outBufferSize > maxBufferSize && *outBufferSize > maxPacketSize) *outBufferSize = maxBufferSize;
    else if(*outBufferSize < minBufferSize) *outBufferSize = minBufferSize;
    
    *outNumPackets = *outBufferSize / maxPacketSize;
}

static void MyCopyEncoderCookieToQueue(AudioFileID file, AudioQueueRef queue)
{
    UInt32 propSize;
    OSStatus err = AudioFileGetPropertyInfo(file, kAudioFilePropertyMagicCookieData, &propSize, NULL);
    
    if (err == noErr && propSize > 0) 
    {
        Byte *magicCookie = (UInt8 *)malloc(sizeof(UInt8) * propSize);
        CheckError(AudioFileGetProperty(file, kAudioFilePropertyMagicCookieData, &propSize, magicCookie), "failed to get cookie data");
        CheckError(AudioQueueSetProperty(queue, kAudioQueueProperty_MagicCookie, magicCookie, propSize), "failed to set cookie on queue");
        free(magicCookie);
    }
}

static void MyCopyEncoderCookieToFile(AudioQueueRef queue, AudioFileID file)
{
    OSStatus err;
    UInt32 propertySize;
    
    err = AudioQueueGetPropertySize(queue, kAudioConverterCompressionMagicCookie, &propertySize);
    
    if(err == noErr && propertySize > 0)
    {
        Byte *magicCookie = (Byte *)malloc(propertySize);
        
        CheckError(AudioQueueGetProperty(
                                         queue, 
                                         kAudioQueueProperty_MagicCookie, 
                                         magicCookie, 
                                         &propertySize), 
                   "can't get magic cookie property from queue");
        
        CheckError(AudioFileSetProperty(file, 
                                        kAudioFilePropertyMagicCookieData, 
                                        propertySize, 
                                        magicCookie), 
                   "can't set magic cookie property to file");
        
        free(magicCookie);
    }
    else
    {
        CheckError(err, "cookie fail");
    }
}
