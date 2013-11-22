//
//  A4TrackingMidiSequencer.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4TrackingMidiSequencer.h"
#import "A4Timepiece.h"
#import <QuartzCore/QuartzCore.h>

@interface A4TrackingMidiSequencer()
@property (nonatomic, strong) NSMutableArray *trackerTracks;
@end
@implementation A4TrackingMidiSequencer


+ (instancetype)trackingSequencerWithDelegate:(id<A4TrackingMidiSequencerDelegate>)delegate outputDevice:(PGMidiDestination *)dst inputDevice:(PGMidiSource *)src
{
	A4TrackingMidiSequencer *instance = [self sequencerWithDelegate:delegate outputDevice:dst inputDevice:src];
	instance.performanceMacroHandler.inputSource = src;
	return instance;
}

- (void)setInputDevice:(PGMidiSource *)inputDevice
{
	[super setInputDevice:inputDevice];
	self.performanceMacroHandler.inputSource = inputDevice;
}

- (void)a4PerformanceMacroHandler:(A4PerformanceMacroHandler *)handler knob:(uint8_t)knob didChangeValue:(uint8_t)value
{
	_sourceKit.macros[knob].value = value;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		for (A4TrackerTrack *track in _trackerTracks)
		{
			if(track.sourceKit)
			{
				A4PerformanceMacro *macro = &track.sourceKit.macros[knob];
				macro->value = value;
				
				const char *bip = "";
				if(macro->bipolar) bip = "BIP";
				printf("performance knob: %c %s \"%s\" value: %d\n", 'A' + knob, bip, macro->name, value);
				for (int i = 0; i < 5; i++)
				{
					A4ModTarget *target = &macro->targets[i];
					printf("\ttgt %d track %d param: 0x%02X depth: %d\n", i, target->track, target->param, (int8_t)target->coarse);
				}
			}
		}
		
	});
}

- (void)setClockMultiplier:(NSInteger)clockMultiplier
{
	[super setClockMultiplier:clockMultiplier];
	for (A4TrackerTrack *track in _trackerTracks)
	{
		track.clockMultiplier = self.clockMultiplier;
	}
}

- (void)setClockInterpolationFactor:(NSInteger)clockInterpolationFactor
{
	[super setClockInterpolationFactor:clockInterpolationFactor];
	for (A4TrackerTrack *track in _trackerTracks)
	{
		track.clockInterpolationFactor = self.clockInterpolationFactor;
	}
}

- (void)a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didOpenGateWithTrig:(A4Trig)trig step:(uint8_t)step context:(TrigContext)ctxt
{
	if(sequencerTrack.trackIdx < 4)
	{
		
		GateEvent proper = sequencerTrack.nextProperGate;
		double time = _time;
		
		
		switch (_trackingMode)
		{
			case A4TrackingMidiSequencerTrackingModeRealtime:
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					
					A4TrackerTrack *trackerTrack = _trackerTracks[sequencerTrack.trackIdx];
					trackerTrack.nextGateEvent = sequencerTrack.nextGate;
					trackerTrack.currentGateEvent = sequencerTrack.currentOpenGate;
					if(ctxt == TrigContextProperTrig)
					{
						trackerTrack.nextProperGateEvent = proper;
						trackerTrack.lastProperGateEvent = sequencerTrack.currentOpenGate;
					}
					
					[self.trackerTracks[sequencerTrack.trackIdx] openGateAtStep:step trig:trig context:ctxt time:time];
				});
				break;
			}
			default:
			{
				A4TrackerTrack *trackerTrack = _trackerTracks[sequencerTrack.trackIdx];
				trackerTrack.nextGateEvent = sequencerTrack.nextGate;
				trackerTrack.currentGateEvent = sequencerTrack.currentOpenGate;
				if(ctxt == TrigContextProperTrig)
				{
					trackerTrack.nextProperGateEvent = proper;
					trackerTrack.lastProperGateEvent = sequencerTrack.currentOpenGate;
				}
				
				[self.trackerTracks[sequencerTrack.trackIdx] openGateAtStep:step trig:trig context:ctxt time:time];
				break;
			}
		}
	}
	[super a4SequencerTrack:sequencerTrack didOpenGateWithTrig:trig step:step context:ctxt];
}

- (void)a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didCloseGateWithTrig:(A4Trig)trig step:(uint8_t)step context:(TrigContext)ctxt
{
	if(sequencerTrack.trackIdx < 4)
	{
		double time = _time;
		switch (_trackingMode)
		{
			case A4TrackingMidiSequencerTrackingModeRealtime:
			{
				dispatch_async(dispatch_get_main_queue(), ^{
					
					[self.trackerTracks[sequencerTrack.trackIdx] closeGateWithContext:ctxt time:time];
					
				});
				break;
			}
			default:
			{
				[self.trackerTracks[sequencerTrack.trackIdx] closeGateWithContext:ctxt time:time];
				break;
			}
		}
	}
	[super a4SequencerTrack:sequencerTrack didCloseGateWithTrig:trig step:step context:ctxt];
}

- (void)a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didOpenTriglessGateWithTrig:(A4Trig)trig step:(uint8_t)step
{
	if(sequencerTrack.trackIdx < 4)
	{
		switch (_trackingMode)
		{
			case A4TrackingMidiSequencerTrackingModeRealtime:
			{
				double time = _time;
				dispatch_async(dispatch_get_main_queue(), ^{
					
					A4TrackerTrack *trackerTrack = _trackerTracks[sequencerTrack.trackIdx];
					trackerTrack.nextGateEventTrigless = sequencerTrack.nextTriglessGate;
					trackerTrack.currentGateEventTrigless = sequencerTrack.currentOpenTriglessGate;
					trackerTrack.nextProperGateEvent = sequencerTrack.nextProperGate;
					if(trackerTrack.lastProperGateEvent.step == -1)
						trackerTrack.lastProperGateEvent = sequencerTrack.currentOpenGate;
					[self.trackerTracks[sequencerTrack.trackIdx] openTriglessGateAtStep:step trig:trig time:time];
					
				});
				break;
			}
			default:
			{
				double time = _time;
				
				A4TrackerTrack *trackerTrack = _trackerTracks[sequencerTrack.trackIdx];
				trackerTrack.nextGateEventTrigless = sequencerTrack.nextTriglessGate;
				trackerTrack.currentGateEventTrigless = sequencerTrack.currentOpenTriglessGate;
				trackerTrack.nextProperGateEvent = sequencerTrack.nextProperGate;
				if(trackerTrack.lastProperGateEvent.step == -1)
					trackerTrack.lastProperGateEvent = sequencerTrack.currentOpenGate;
				[self.trackerTracks[sequencerTrack.trackIdx] openTriglessGateAtStep:step trig:trig time:time];
				
				break;
			}
		}
	}
	[super a4SequencerTrack:sequencerTrack didOpenTriglessGateWithTrig:trig step:step];
}

- (void)a4SequencerTrack:(A4SequencerTrack *)sequencerTrack didCloseTriglessGateWithTrig:(A4Trig)trig step:(uint8_t)step
{
	if(sequencerTrack.trackIdx < 4)
	{
		switch (_trackingMode)
		{
			case A4TrackingMidiSequencerTrackingModeRealtime:
			{
				double time = _time;
				dispatch_async(dispatch_get_main_queue(), ^{
					
					[self.trackerTracks[sequencerTrack.trackIdx] closeTriglessGateWithTime:time];
					
				});
				break;
			}
			default:
			{
				double time = _time;
				[self.trackerTracks[sequencerTrack.trackIdx] closeTriglessGateWithTime:time];
				break;
			}
		}
	}
	[super a4SequencerTrack:sequencerTrack didCloseTriglessGateWithTrig:trig step:step];
}

- (id)init
{
	if(self = [super init])
	{
		self.targetParams = malloc(sizeof(double*) * 4);
		self.trackerTracks = @[].mutableCopy;
		
		for(int i = 0; i < 4; i++)
		{
			A4TrackerParam_t *trackParams = calloc(A4ParamLockableCount, sizeof(double));
			trackParams[0] = 123;
			self.targetParams[i] = trackParams;
			A4TrackerTrack *track = [A4TrackerTrack new];
			track.paramsPostNote = trackParams;
			track.trackIdx = i;
			track.sequencer = self;
			[self.trackerTracks addObject:track];
			self.performanceMacroHandler = [A4PerformanceMacroHandler performanceMacroHandlerWithDelegate:self inputSource:nil channel:7];
		}
		
		self.project = self.project;
	}
	return self;
}

- (void)dealloc
{
	for (int i = 0; i < 4; i++)
	{
		free(self.targetParams[i]);
	}
	free(self.targetParams);
}

- (void)setPattern:(A4Pattern *)pattern
{
	uint8_t kitIdx = pattern.kit;
	if(kitIdx < 0 || kitIdx > 127) kitIdx = 0;
	self.sourceKit = [self.project kitAtPosition:kitIdx copy:YES];
	
	for(int i = 0; i < 4; i++)
	{
		A4TrackerTrack *trackerTrack = _trackerTracks[i];
		trackerTrack.sourceTrack = [pattern track:i];
	}
	
	[super setPattern:pattern];
}

- (void)handleClock
{
	@synchronized(self)
	{
		[super handleClock];
		
		switch (_trackingMode)
		{
			case A4TrackingMidiSequencerTrackingModeRealtime:
			{
				_time = CACurrentMediaTime();
				break;
			}
			default:
				break;
		}
		
		[A4Timepiece tickWithTime:_time];
		
		double time = _time;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			for (A4TrackerTrack *track in _trackerTracks)
			{
				[track tickWithTime:time];
			}
			
		});
	}
}

- (void)start
{
	switch (_trackingMode)
	{
		case A4TrackingMidiSequencerTrackingModeRealtime:
		{
			dispatch_async(dispatch_get_main_queue(), ^{
				
				for(A4TrackerTrack *trk in _trackerTracks)
				{
					trk.lastProperGateEvent = gateEventNull();
					trk.nextProperGateEvent = gateEventNull();
				}
				
			});
			break;
		}
		default:
		{
			for(A4TrackerTrack *trk in _trackerTracks)
			{
				trk.lastProperGateEvent = gateEventNull();
				trk.nextProperGateEvent = gateEventNull();
			}
			break;
		}
	}
	[super start];
}

- (void)setSourceKit:(A4Kit *)sourceKit
{
	printf("kit pos: %d\n", sourceKit.position);
	_sourceKit = sourceKit;
	for(int i = 0; i < 4; i++)
	{
		A4TrackerTrack *track = _trackerTracks[i];
		char *payload = malloc(A4MessagePayloadLengthKit);
		memmove(payload, _sourceKit.payload, A4MessagePayloadLengthKit);
		A4Kit *kit = [A4Kit messageWithPayloadAddress:payload];
		track.sourceKit = kit;
	}
}

- (void)setProject:(A4Project *)project
{
	[super setProject:project];
	for(int i = 0; i < 4; i++)
	{
		A4TrackerTrack *track = _trackerTracks[i];
		track.sourceProject = project;
	}
	
	[self setPattern:[self.project patternAtPosition:self.pattern.position] mode:A4SequencerModeQueue];
}

- (void)updateContinuousValues
{
	switch (_trackingMode)
	{
		case A4TrackingMidiSequencerTrackingModeRealtime:
		{
			_time = CACurrentMediaTime();
			break;
		}
		default:
			break;
	}
	for(A4TrackerTrack *track in self.trackerTracks)
	{
		[track updateContinuousValuesWithTime:_time];
	}
}

@end
