//
//  A4TrackerTrack.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4TrackerTrack.h"
#import "A4SequencerTrack.h"
#import <QuartzCore/QuartzCore.h>
#import "A4Timepiece.h"
#import "A4Sequencer.h"
#import "A4Envelope.h"
#import "A4LFO.h"
#import "MDMath.h"

typedef struct ParameterSlide
{
	A4Param param;
	A4TrackerParam_t startTime;
	A4TrackerParam_t duration;
	A4TrackerParam_t fromValNormalized;
	A4TrackerParam_t toValNormalized;
}
ParameterSlide;

@interface A4TrackerTrack()
@property (nonatomic, strong) A4Sound *currentSourceSound;
@property (nonatomic) A4Trig currentTrig, currentTriglessTrig;
@property (nonatomic) BOOL trigGateIsOpen, triglessGateIsOpen;
@property (nonatomic) A4PVal *locksBuf, *locksBufNext;
@property (nonatomic) uint8_t locksBufLen, locksBufLenNext;
@property (nonatomic) TrigContext currentTrigContext;
@property (nonatomic) ParameterSlide *parameterSlides;
@property (nonatomic) uint8_t parameterSlidesLen;
@property (nonatomic) uint8_t lastNote;
@property (nonatomic) A4Envelope *envelopeAmp, *envelope1, *envelope2;
@property (nonatomic) A4LFO *lfo1, *lfo2;
@property (nonatomic) A4Kit *queuedSourceKit;
@property (nonatomic) BOOL doTrigLFOs;
@end

@implementation A4TrackerTrack

- (void)setNextProperGateEvent:(GateEvent)nextProperGateEvent
{
	_lastProperGateEvent = _nextProperGateEvent;
	_nextProperGateEvent = nextProperGateEvent;
}

- (id)init
{
	if(self = [super init])
	{
		_clockInterpolationFactor = 1;
		_clockMultiplier = 6;
		_lastNote = A4NULL;
		_lastProperGateEvent = gateEventNull();
		_nextProperGateEvent = gateEventNull();
		_locksBuf = malloc(sizeof(A4PVal) * 128);
		_locksBufNext = malloc(sizeof(A4PVal) * 128);
		_parameterSlides = malloc(sizeof(ParameterSlide) * A4ParamLockableCount);
		
		_paramsPostParams = malloc(sizeof(A4TrackerParam_t) * A4ParamLockableCount);
		_paramsPostLocks = malloc(sizeof(A4TrackerParam_t) * A4ParamLockableCount);
		_paramsPostModulations = malloc(sizeof(A4TrackerParam_t) * A4ParamLockableCount);
		
		_envelopeAmp = [A4Envelope new];
		_envelope2 = [A4Envelope new];
		_envelope1 = [A4Envelope new];
		
		_lfo1 = [A4LFO new];
		_lfo2 = [A4LFO new];
	}
	return self;
}

- (void)dealloc
{
	free(_locksBuf);
	free(_locksBufNext);
	free(_parameterSlides);
	
	free(_paramsPostParams);
	free(_paramsPostLocks);
	free(_paramsPostModulations);
}

- (void)setClockInterpolationFactor:(NSInteger)clockInterpolationFactor
{
	if(clockInterpolationFactor < 1) return;
	_clockInterpolationFactor = clockInterpolationFactor;
	_lfo1.clockInterpolationFactor = clockInterpolationFactor;
	_lfo2.clockInterpolationFactor = clockInterpolationFactor;
}

- (void)setSourceKit:(A4Kit *)sourceKit
{
	[self setSourceKit:sourceKit immediately:NO];
}

- (void)setSourceKit:(A4Kit *)sourceKit immediately:(BOOL)immediately
{
	BOOL doIt = NO;
	if(! _sourceKit) doIt = YES;
	if(! doIt && memcmp(_sourceKit.payload + 0x20 + _trackIdx * A4MessagePayloadLengthSound,
					  sourceKit.payload + 0x20 + _trackIdx * A4MessagePayloadLengthSound, A4MessagePayloadLengthSound))
	{
		
		doIt = YES;
	}
	if(doIt)
	{
		self.queuedSourceKit = sourceKit;
		if(immediately) [self applyQueuedSourceKit];
	}
}

- (void) applyQueuedSourceKit
{
	if(!_queuedSourceKit) return;
	
	if (! [_sourceKit isEqualToKit:_queuedSourceKit])
	{
		[_envelopeAmp reset];
		[_envelope1 reset];
		[_envelope2 reset];
	}

	_sourceKit = _queuedSourceKit;
	_queuedSourceKit = nil;
	
	A4Sound *sourceSound = [_sourceKit soundAtTrack:_trackIdx copy:NO];
	for(int i = 0; i < A4ParamLockableCount; i++)
	{
		A4Param param = A4ParamLockableByIndex(i);
		_paramsPostParams[i] = A4PValDoubleVal([sourceSound valueForParam:param]);
	}
	
	size_t byteCount = A4ParamLockableCount * sizeof(A4TrackerParam_t);
	memmove(_paramsPostLocks, _paramsPostParams, byteCount);
	memmove(_paramsPostModulations, _paramsPostParams, byteCount);
	memmove(_paramsPostNote, _paramsPostParams, byteCount);
}

- (void)setCurrentSourceSound:(A4Sound *)currentSourceSound
{
	_currentSourceSound = currentSourceSound;
	
	for(int i = 0; i < A4ParamLockableCount; i++)
	{
		A4PVal pval = [_currentSourceSound valueForParam:A4ParamLockableByIndex(i)];
		_paramsPostParams[i] = A4PValDoubleVal(pval);
		
		if (_currentTrigContext == TrigContextProperTrig)
		{
			_paramsPostLocks[i] = _paramsPostParams[i];
		}
	}
	
	if(_currentTrigContext == TrigContextProperTrig && _lastProperGateEvent.step != -1)
	{
		_locksBufLen = 0;
		if(A4LocksForTrackAndStep(_sourceTrack.pattern, _lastProperGateEvent.step, _trackIdx, _locksBuf, &_locksBufLen))
		{
			for(int i = 0; i < _locksBufLen; i++)
			{
				uint8_t j = A4ParamIndexOfParamLockableParams(_locksBuf[i].param);
				_paramsPostLocks[j] = A4PValDoubleVal(_locksBuf[i]);
			}
		}
	}
}

- (void) setSourceTrack:(A4PatternTrack *)sourceTrack
{
	_sourceTrack = sourceTrack;
	if(_lastNote == A4NULL) _lastNote = sourceTrack.settings->trigNote;
}

- (void)tickWithTime:(A4TrackerParam_t)time
{
	_lfo2.mode = _paramsPostLocks[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO2.MODE)];
	_lfo1.mode = _paramsPostLocks[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO1.MODE)];
	[_lfo2 tickWithTime:time trig:_doTrigLFOs];
	[_lfo1 tickWithTime:time trig:_doTrigLFOs];
	_doTrigLFOs = NO;
}


- (void)openGateAtStep:(uint8_t)step trig:(A4Trig)trig context:(TrigContext)context time:(A4TrackerParam_t)time
{
	NSAssert(_paramsPostNote, @"params post note must not be NULL");
	
	_trigGateIsOpen = YES;
	_currentTrig = trig;
	_currentTrigContext = context;
	
	if(trig.note != A4NULL) _lastNote = trig.note;
	

	if(trig.soundLock != A4NULL)
	{
		self.currentSourceSound = [_sourceProject soundAtPosition:trig.soundLock copy:YES];
	}
	else
	{
		if(self.queuedSourceKit) [self applyQueuedSourceKit];
		self.currentSourceSound = [self.sourceKit soundAtTrack:_trackIdx copy:NO];
	}
	
	[self refreshParameterSlidesWithTime:time];

	if(trig.flags & A4TRIGFLAGS.ENV1)
	{
		if(_envelope1.isOpen)[_envelope1 closeWithTime:time];
		[_envelope1 openWithTime:time];
	}
	if(trig.flags & A4TRIGFLAGS.ENV2)
	{
		if(_envelope2.isOpen)[_envelope2 closeWithTime:time];
		[_envelope2 openWithTime:time];
	}
	if(trig.flags & A4TRIGFLAGS.TRIG)
	{
		if(_envelopeAmp.isOpen)[_envelopeAmp closeWithTime:time];
		[_envelopeAmp openWithTime:time];
	}
	
	
	if(trig.flags & A4TRIGFLAGS.LFO1)
	{
		[_lfo1 restart];
	}
	if(trig.flags & A4TRIGFLAGS.LFO2)
	{
		[_lfo2 restart];
	}
	
	_doTrigLFOs = YES;
}

- (void)openTriglessGateAtStep:(uint8_t)step trig:(A4Trig)trig time:(A4TrackerParam_t)time
{
	NSAssert(_paramsPostNote, @"params post note must not be NULL");
	
	_triglessGateIsOpen = YES;
	_currentTriglessTrig = trig;
	_locksBufLen = 0;
	if(trig.note != A4NULL) _lastNote = trig.note;
	
	if(A4LocksForTrackAndStep(_sourceTrack.pattern, step, _trackIdx, _locksBuf, &_locksBufLen))
	{
		for(int i = 0; i < _locksBufLen; i++)
		{
			int j = A4ParamIndexOfParamLockableParams(_locksBuf[i].param);
			A4TrackerParam_t val = A4PValDoubleVal(_locksBuf[i]);
			_paramsPostLocks[j] = val;
			_paramsPostModulations[j] = val;
			_paramsPostNote[j] = val;
		}
	}
	[self refreshParameterSlidesWithTime:time];
	
	if(trig.flags & A4TRIGFLAGS.ENV1)
	{
		[_envelope1 closeWithTime:time];
		[_envelope1 openWithTime:time];
	}
	if(trig.flags & A4TRIGFLAGS.ENV2)
	{
		[_envelope2 closeWithTime:time];
		[_envelope2 openWithTime:time];
	}
}

- (void)closeGateWithContext:(TrigContext)context time:(A4TrackerParam_t)time
{
	[_envelope1 closeWithTime:time];
	[_envelope2 closeWithTime:time];
	[_envelopeAmp closeWithTime:time];
	_trigGateIsOpen = NO;
}

- (void)closeTriglessGateWithTime:(A4TrackerParam_t)time
{
	_triglessGateIsOpen = NO;
	_currentTriglessTrig = A4TrigMakeEmpty();
}


- (void) updateTargetSoundTuningsWithNoteValue
{
	A4TrackerParam_t trk = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_OSC1.KEYTRACK)];
	if(trk > .1)
	{
		int i = A4ParamIndexOfParamLockableParams(A4PARAMS_OSC1.TUNING);
		A4TrackerParam_t tun = _paramsPostModulations[i];
		
		if(_lastNote != A4NULL)
		{
			tun -= 60;
			tun += _lastNote;
		}
				
		_paramsPostNote[i] = mdmath_clamp(tun, 0, 128);
	}
	
	trk = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_OSC2.KEYTRACK)];
	if(trk > .1)
	{
		int i = A4ParamIndexOfParamLockableParams(A4PARAMS_OSC2.TUNING);
		A4TrackerParam_t tun = _paramsPostModulations[i];
		
		if(_lastNote != A4NULL)
		{
			tun -= 60;
			tun += _lastNote;
		}
				
		_paramsPostNote[i] = mdmath_clamp(tun, 0, 128);
	}
}


- (void) updateTargetFilterTrackingWithNoteValue
{
	if(_lastNote != A4NULL)
	{
		int i = A4ParamIndexOfParamLockableParams(A4PARAMS_FILT.F1_FREQUENCY);
		A4TrackerParam_t trk = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_FILT.F1_KEYTRACK)];
		A4TrackerParam_t tun = _paramsPostModulations[i];
		
		trk-=64;
		trk/=32;
		
		tun += trk * (_lastNote - 60);
		_paramsPostNote[i] = mdmath_clamp(tun, 0, 128);
		
		i = A4ParamIndexOfParamLockableParams(A4PARAMS_FILT.F2_FREQUENCY);
		trk = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_FILT.F2_KEYTRACK)];
		tun = _paramsPostModulations[i];
		
		trk-=64;
		trk /= 32;
		tun += trk * (_lastNote - 60);
		_paramsPostNote[i] = mdmath_clamp(tun, 0, 128);
	}
}


- (void) refreshParameterSlidesWithTime:(A4TrackerParam_t)time
{
	_parameterSlidesLen = 0;
	if(_nextProperGateEvent.step == -1) return;
	GateEvent nextGateEvent, currentGateEvent = gateEventNull();
	
	if([_sourceTrack trigAtStep:_lastProperGateEvent.step].flags & A4TRIGFLAGS.PARAMSLIDE)
	{
		currentGateEvent = _lastProperGateEvent;
	}
	else
	{
		return;
	}
	
	nextGateEvent = _nextProperGateEvent;
	
	int numberOfClocksBetweenEvents = -1;
	uint8_t trackLenSteps =
	_sourceTrack.pattern.timeMode == A4PatternTimeModeAdvanced ?
	_sourceTrack.settings->trackLength : _sourceTrack.pattern.masterLength;
	
	if(nextGateEvent.clockOn > -1)
	{
		if(currentGateEvent.clockOn < nextGateEvent.clockOn)
			numberOfClocksBetweenEvents = nextGateEvent.clockOn - currentGateEvent.clockOn;
		else
		{
			int lenClocks = (trackLenSteps - currentGateEvent.step) * _clockMultiplier * _clockInterpolationFactor;
			lenClocks += nextGateEvent.step;
			numberOfClocksBetweenEvents = lenClocks;
		}
	}
	
	if(numberOfClocksBetweenEvents == -1) return;

	A4TrackerParam_t duration = 0;
	A4TrackerParam_t secondsPerClock = [A4Timepiece secondsBetweenClockTicks];
	
	duration = secondsPerClock * numberOfClocksBetweenEvents;
	if(duration <= 0) return;
	
	for(int i = 0; i < _locksBufLen; i++)
	{
		if( ! A4ParamIsSlideable(_locksBuf[i].param)) continue;
		
		A4PVal lockFrom = _locksBuf[i];
		
		int idx = A4ParamIndexOfParamLockableParams(lockFrom.param);
		A4TrackerParam_t valFrom = _paramsPostLocks[idx];
		A4TrackerParam_t valTo = -1;
		A4PVal lockTo = [_sourceTrack.pattern lockForParam:lockFrom.param atStep:nextGateEvent.step inTrack:_trackIdx];
		
		
		if(lockTo.param == A4NULL && nextGateEvent.type != GateEventTypeTrigless)
		{
			valTo = _paramsPostParams[idx];
		}
		else if (lockTo.param != A4NULL)
		{
			valTo = A4PValDoubleVal(lockTo);
		}
		
		A4TrackerParam_t fromValNormalized = valFrom/A4ParamMax(lockFrom.param);
		A4TrackerParam_t toValNormalized = valTo/A4ParamMax(lockFrom.param);
		
		if(fromValNormalized != toValNormalized)
		{
			_parameterSlides[_parameterSlidesLen].param = lockFrom.param;
			_parameterSlides[_parameterSlidesLen].fromValNormalized = fromValNormalized;
			_parameterSlides[_parameterSlidesLen].toValNormalized = toValNormalized;
			_parameterSlides[_parameterSlidesLen].startTime = time;
			_parameterSlides[_parameterSlidesLen].duration = duration;
			_parameterSlidesLen++;
		}
	}
	
	if(currentGateEvent.type == GateEventTypeTrig && A4LocksForTrackAndStep(_sourceTrack.pattern, nextGateEvent.step, _trackIdx, _locksBufNext, &_locksBufLenNext))
	{
		for(int i = 0; i < _locksBufLenNext; i++)
		{
			A4PVal lockTo = _locksBufNext[i];
			if( ! A4ParamIsSlideable(lockTo.param)) continue;
			
			BOOL hasAlreadyBeenAdded = NO;
			for(int j = 0; j < _parameterSlidesLen; j++)
			{
				if(_parameterSlides[j].param == lockTo.param) hasAlreadyBeenAdded = YES;
				break;
			}
			
			if( ! hasAlreadyBeenAdded)
			{
				int idx = A4ParamIndexOfParamLockableParams(lockTo.param);
				A4TrackerParam_t fromValNormalized = _paramsPostLocks[idx] / A4ParamMax(lockTo.param);
				A4TrackerParam_t toValNormalized = A4PValDoubleValNormalized(lockTo);

				if(fromValNormalized != toValNormalized)
				{
					_parameterSlides[_parameterSlidesLen].param = lockTo.param;
					_parameterSlides[_parameterSlidesLen].fromValNormalized = fromValNormalized;
					_parameterSlides[_parameterSlidesLen].toValNormalized = toValNormalized;
					_parameterSlides[_parameterSlidesLen].startTime = time;
					_parameterSlides[_parameterSlidesLen].duration = duration;
					_parameterSlidesLen++;
				}
			}
		}
	}
}



- (void) updateContinuousValuesWithTime:(A4TrackerParam_t)time
{
	NSAssert(_paramsPostNote, @"params post note must not be NULL");

	memmove(_paramsPostModulations, _paramsPostLocks, A4ParamLockableCount * sizeof(A4TrackerParam_t));
	
	
	[self updateParameterSlidesWithTime:time];
	[self updatePerformanceMacros];
	[self updateLFO2WithTime:time];
	[self updateEnvelope2WithTime:time];
	[self updateLFO1WithTime:time];
	[self updateEnvelope1WithTime:time];
	[self updateAccent];
	[self updateEnvelope1FilterDepth];
	[self updateAmpEnvelopeWithTime:time];

	memmove(_paramsPostNote, _paramsPostModulations, sizeof(A4TrackerParam_t) * A4ParamLockableCount);
	
	[self updateTargetSoundTuningsWithNoteValue];
	[self updateTargetFilterTrackingWithNoteValue];
	
}

- (void) updateParameterSlidesWithTime:(A4TrackerParam_t)time
{
	for(int i = 0; i < _parameterSlidesLen; i++)
	{
		ParameterSlide slide = _parameterSlides[i];
		if(time >= slide.startTime)
		{
			A4TrackerParam_t progressNormalized = (time - slide.startTime) / slide.duration;
			A4TrackerParam_t normalizedVal = ((1-progressNormalized) * slide.fromValNormalized + progressNormalized * slide.toValNormalized);
			normalizedVal = mdmath_clamp(normalizedVal, 0, 1);
			int idx = A4ParamIndexOfParamLockableParams(slide.param);
			_paramsPostModulations[idx] = normalizedVal * A4ParamMax(slide.param);
		}
	}
}

- (void) updatePerformanceMacros
{
	if(_currentTrig.soundLock != A4NULL) return;
	
	for(int macroIdx = 0; macroIdx < A4PerformanceMacroCount; macroIdx++)
	{
		A4PerformanceMacro *macro = &_sourceKit.macros[macroIdx];
		A4TrackerParam_t macroValue = macro->value;
		if(macro->bipolar) macroValue -= 64;
		
		for (int targetIdx = 0; targetIdx < 5; targetIdx++)
		{
			A4ModTarget *target = &macro->targets[targetIdx];
			if(target->track == _trackIdx)
			{
				A4TrackerParam_t targetDepth = (int8_t)target->coarse;
				A4TrackerParam_t modDepth = targetDepth * macroValue/128.0;
				
				[self applyModulationsWithDepth: modDepth target:target->param];
			}
		}
	}
}

- (void) updateLFO2WithTime:(double)time
{
	_lfo2.speed = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO2.SPEED)];
	_lfo2.multiplier = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO2.MULTIPLIER)];
	_lfo2.startPhase = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO2.SPEED)];
	_lfo2.speed = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO2.SPEED)];
	_lfo2.shape = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO2.WAVEFORM)];
	_lfo2.mode = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO2.MODE)];
	
	A4TrackerParam_t depth = [_lfo2 lfoValueWithTime:time];
	
	A4PVal pval = [_currentSourceSound valueForParam:A4PARAMS_LFO2.DESTINATION_A];
	A4Param target = pval.coarse;
	A4TrackerParam_t modDepth = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO2.DEPTH_A)];
	modDepth -= 64;
	
	[self applyModulationsWithDepth: modDepth * depth * 2 target:target];
	
	pval = [_currentSourceSound valueForParam:A4PARAMS_LFO2.DESTINATION_B];
	target = pval.coarse;
	modDepth = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO2.DEPTH_B)];
	modDepth -= 64;
	
	[self applyModulationsWithDepth: modDepth * depth * 2 target:target];
}

- (void) updateLFO1WithTime:(double) time
{
	_lfo1.speed = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO1.SPEED)];
	_lfo1.multiplier = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO1.MULTIPLIER)];
	_lfo1.startPhase = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO1.SPEED)];
	_lfo1.speed = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO1.SPEED)];
	_lfo1.shape = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO1.WAVEFORM)];
	_lfo1.mode = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO1.MODE)];
	
	A4TrackerParam_t depth = [_lfo1 lfoValueWithTime:time];
	
	A4PVal pval = [_currentSourceSound valueForParam:A4PARAMS_LFO1.DESTINATION_A];
	A4Param target = pval.coarse;
	A4TrackerParam_t modDepth = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO1.DEPTH_A)];
	modDepth -= 64;
	
	[self applyModulationsWithDepth: modDepth * depth * 2 target:target];
	
	pval = [_currentSourceSound valueForParam:A4PARAMS_LFO1.DESTINATION_B];
	target = pval.coarse;
	modDepth = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_LFO1.DEPTH_B)];
	modDepth -= 64;
	
	[self applyModulationsWithDepth: modDepth * depth * 2 target:target];
}



- (void) updateAccent
{
	if(_lastProperGateEvent.step != -1)
	{
		A4Trig trig = _currentTrig;
		
		if(trig.flags & A4TRIGFLAGS.ACCENT)
		{
			A4TrackerParam_t accentLevel = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_AMP.ACCENT)];
			
			int modIdx = A4ParamIndexOfParamLockableParams(A4PARAMS_FILT.F1_MODDEPTH);
			A4TrackerParam_t modVal = _paramsPostModulations[modIdx];
			modVal = mdmath_clamp(modVal + accentLevel, 0, A4ParamMax(A4PARAMS_FILT.F1_MODDEPTH));
			_paramsPostModulations[modIdx] = modVal;
			
			modIdx = A4ParamIndexOfParamLockableParams(A4PARAMS_FILT.F2_MODDEPTH);
			modVal = _paramsPostModulations[modIdx];
			modVal = mdmath_clamp(modVal + accentLevel, 0, A4ParamMax(A4PARAMS_FILT.F2_MODDEPTH));
			_paramsPostModulations[modIdx] = modVal;
		}
	}
}


- (void) updateEnvelope2WithTime:(A4TrackerParam_t)time
{
	if(!_currentSourceSound) return;
	
	_envelope2.shape =		_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV2.SHAPE)];
	_envelope2.attackVal =	_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV2.ENV_ATTACK)];
	_envelope2.decayVal =	_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV2.ENV_DECAY)];
	_envelope2.sustainVal = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV2.ENV_SUSTAIN)];
	_envelope2.releaseVal = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV2.ENV_RELEASE)];
	
	// TODO: update env values when ADSR params change!
	// TODO: custom gate length!
	 
	[_envelope2 updateWithTime:time];
	A4TrackerParam_t envval = _envelope2.normalizedValue;
	
	A4PVal pval = [_currentSourceSound valueForParam:A4PARAMS_ENV2.DESTINATION_A];
	A4Param target = pval.coarse;
	A4TrackerParam_t depthVal = (_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV2.DEPTH_A)] - 64) * 2 * envval;
	[self applyModulationsWithDepth:depthVal target:target];
	
	pval = [_currentSourceSound valueForParam:A4PARAMS_ENV2.DESTINATION_B];
	target = pval.coarse;
	depthVal = (_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV2.DEPTH_B)] - 64) * 2 * envval;
	[self applyModulationsWithDepth:depthVal target:target];
}

- (void) updateEnvelope1WithTime:(A4TrackerParam_t)time
{
	if(!_currentSourceSound) return;
	
	_envelope1.shape =		_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV1.SHAPE)];
	_envelope1.attackVal =	_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV1.ENV_ATTACK)];
	_envelope1.decayVal =	_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV1.ENV_DECAY)];
	_envelope1.sustainVal = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV1.ENV_SUSTAIN)];
	_envelope1.releaseVal = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV1.ENV_RELEASE)];
	
	// TODO: update env values when ADSR params change!
	// TODO: custom gate length!
	
	[_envelope1 updateWithTime:time];
	A4TrackerParam_t envval = _envelope1.normalizedValue;
	
	A4PVal pval = [_currentSourceSound valueForParam:A4PARAMS_ENV1.DESTINATION_A];
	A4Param target = pval.coarse;
	A4TrackerParam_t depthVal = (_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV1.DEPTH_A)] - 64) * 2 * envval;
	[self applyModulationsWithDepth:depthVal target:target];
	
	pval = [_currentSourceSound valueForParam:A4PARAMS_ENV1.DESTINATION_B];
	target = pval.coarse;
	depthVal = (_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_ENV1.DEPTH_B)] - 64) * 2 * envval;
	[self applyModulationsWithDepth:depthVal target:target];
}

- (void) applyModulationsWithDepth:(A4TrackerParam_t)depthVal target:(A4Param) target
{
	if(target == A4ParamOsc1Pit) target = A4ParamOsc1Tun;
	if(target == A4ParamOsc2Pit) target = A4ParamOsc2Tun;
	if(target == A4ParamOsc12Pi)
	{
		int idx = A4ParamIndexOfParamLockableParams(A4PARAMS_OSC1.TUNING);
		A4TrackerParam_t val = _paramsPostModulations[idx];
		val = mdmath_clamp(val + depthVal, 0, 128);
		_paramsPostModulations[idx] = val;
		
		idx = A4ParamIndexOfParamLockableParams(A4PARAMS_OSC2.TUNING);
		val = _paramsPostModulations[idx];
		val = mdmath_clamp(val + depthVal, 0, 128);
		_paramsPostModulations[idx] = val;
	}
	else if(target == A4ParamFiltF12)
	{
		int idx = A4ParamIndexOfParamLockableParams(A4PARAMS_FILT.F1_FREQUENCY);
		A4TrackerParam_t val = _paramsPostModulations[idx];
		val = mdmath_clamp(val + depthVal, 0, 128);
		_paramsPostModulations[idx] = val;
		
		idx = A4ParamIndexOfParamLockableParams(A4PARAMS_FILT.F2_FREQUENCY);
		val = _paramsPostModulations[idx];
		val = mdmath_clamp(val + depthVal, 0, 128);
		_paramsPostModulations[idx] = val;
	}
	else
	{
		int idx = A4ParamIndexOfParamLockableParams(target);
		A4TrackerParam_t val = _paramsPostModulations[idx];
		val = mdmath_clamp(val + depthVal, A4ParamMin(target), A4ParamMax(target));
		_paramsPostModulations[idx] = val;
	}
}

- (void) updateEnvelope1FilterDepth
{
	A4TrackerParam_t envval = _envelope1.normalizedValue;
	A4TrackerParam_t mod = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_FILT.F1_MODDEPTH)];
	
	mod = (mod - 64) * envval;
	int idx = A4ParamIndexOfParamLockableParams(A4PARAMS_FILT.F1_FREQUENCY);
	A4TrackerParam_t frq = _paramsPostModulations[idx];
	frq = mdmath_clamp(frq + mod, 0, 128);
	_paramsPostModulations[idx] = frq;
	
	mod = _paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_FILT.F2_MODDEPTH)];
	mod = (mod - 64) * envval;
	idx = A4ParamIndexOfParamLockableParams(A4PARAMS_FILT.F2_FREQUENCY);
	frq = _paramsPostModulations[idx];
	frq = mdmath_clamp(frq + mod, 0, 128);
	_paramsPostModulations[idx] = frq;
}

- (void) updateAmpEnvelopeWithTime:(A4TrackerParam_t)time
{
	_envelopeAmp.shape =		_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_AMP.SHAPE)];
	_envelopeAmp.attackVal =	_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_AMP.ENV_ATTACK)];
	_envelopeAmp.decayVal =		_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_AMP.ENV_DECAY)];
	_envelopeAmp.sustainVal =	_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_AMP.ENV_SUSTAIN)];
	_envelopeAmp.releaseVal =	_paramsPostModulations[A4ParamIndexOfParamLockableParams(A4PARAMS_AMP.ENV_RELEASE)];
	
	int idx = A4ParamIndexOfParamLockableParams(A4PARAMS_AMP.VOLUME);
	[_envelopeAmp updateWithTime:time];
	A4TrackerParam_t envval = _envelopeAmp.normalizedValue;
	A4TrackerParam_t ampVal = _paramsPostModulations[idx];
	ampVal *= envval * (_currentTrig.velocity/128.0);
	ampVal = mdmath_clamp(ampVal, 0, 128);
	_paramsPostModulations[idx] = ampVal;
}

@end













