//
//  MDProcedureScaleFilter.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 6/27/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import "MDProc.h"
#import "MDPitch.h"

@interface MDProcedureScaleFilter : MDProc
@property MDPitchNotes baseNote;
@property (strong) NSMutableArray *scale;
@end
