//
//  PatternTranslate.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/22/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "PatternTranslate.h"
#import "MDMachinedrumPublic.h"

@implementation PatternTranslate


static PatternTranslate *shared = nil;

+ (PatternTranslate *)sharedInstance
{
	if(shared == nil)
	{
		shared = [PatternTranslate new];
	}
	return shared;
}

- (void)translateCurrentMDPatternForA4
{
	
	
	
	
	[[MDMIDI sysex] request:MDSysexTransactionContextCurrentPattern
				  arguments:nil
				   priority:MDSysexTransactionQueuePriorityLow
			   onCompletion:^(MDSysexTransaction *t) {
				  
				   
				   
				   
				   int scale[] = {0,2,3,5,7,8,10,12};
				   int scaleLen = 8;

				   
				   MDPattern *mdp = t.returnedObject;
				   A4Pattern *a4p = [A4Pattern defaultPattern];
				   
				   a4p.masterLength = mdp.length;
				   
				   for (int track = 0; track < 4; track++)
				   {
					   int octave = 2+arc4random_uniform(6);
					   int base = 12*octave;
					   
					   int div = 1 + arc4random_uniform(4);
					   int laststep = -1;
					   
					   for (int step = 0; step < 64; step++)
					   {
						   if([mdp trigAtTrack:track step:step])
						   {
							   if(laststep != -1)
							   {
								   int numSteps = div - 1;
								   
								   for (int i = 0; i < numSteps; i++)
								   {
									   float d = (step - laststep) * (1.0/div);
									   
									   float ideal = laststep + d * (i+1);
									   int rounded = roundf(ideal);
									   float off = ideal-rounded;
									   
									   
									   int note = base + scale[arc4random_uniform(scaleLen)];
									   
									   
									   A4Trig trig = A4TrigMakeDefault();
									   trig.note = note;
									   trig.microTiming = mdmath_clamp(mdmath_map(off, 1, -1, 24, -24), -23, 23);
									   
									   
									   [[a4p track:track] setTrig:trig atStep:rounded];
								   }
								   
							   }
							   
							   laststep = step;
						   }
					   }
				   }
				   a4p.position = mdp.savePosition;
				   a4p.kit = arc4random_uniform(128);
				   [a4p send];
				   
			   } onError:^(MDSysexTransaction *t) {
				   DLog(@"nah...");
			   }];
}

@end
