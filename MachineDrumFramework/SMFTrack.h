//
//  StandardMidiFileTrack.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/02/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMFEvent.h"

@interface SMFTrack : NSObject
@property (nonatomic, strong) NSMutableArray *trackEvents;
@property (nonatomic, strong) NSData *data;
@end
