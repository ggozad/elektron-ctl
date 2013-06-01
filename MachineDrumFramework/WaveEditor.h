//
//  WaveEditor.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 3/18/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef enum WaveEditorZeroCrossingDirection
{
	WaveEditorZeroCrossingDirectionUp,
	WaveEditorZeroCrossingDirectionDown,
	WaveEditorZeroCrossingDirectionAny
}
WaveEditorZeroCrossingDirection;

@interface WaveEditor : NSObject
@property AudioStreamBasicDescription asbd;
@property (strong, nonatomic) NSData *data;
@property (strong, nonatomic) NSString *path;

+ (id) waveEditorWithFileAtPath:(NSString *)path;
+ (void) printASBD: (AudioStreamBasicDescription) asbd;
- (void) trimAudioWithStartSample:(NSUInteger)start endSample:(NSUInteger)endSample;
- (void) writeAudioData;

//- (NSData *) audioDataForFileAtPath:(NSString *)path;
//- (AudioStreamBasicDescription) asbdForFileAtPath:(NSString *)path;
- (NSArray *) zeroCrossingsForAudioData:(NSData *)d minDist:(NSUInteger)minDist direction:(WaveEditorZeroCrossingDirection) dir;

@end
