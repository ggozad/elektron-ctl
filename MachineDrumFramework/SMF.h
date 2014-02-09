//
//  StandardMidiFile.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMFTrack.h"


typedef enum SMFFormat
{
	SMFFormatSingleTrack,
	SMFFormatMultiTrack,
	SMFFormatMultiSong
}
SMFFormat;

@interface SMF : NSObject
@property (nonatomic, strong) NSMutableArray *tracks;
@property (nonatomic, strong) NSData *data;
@property (nonatomic) SMFFormat format;

@end
