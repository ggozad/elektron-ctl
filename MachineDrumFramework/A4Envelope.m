//
//  A4Envelope.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 14/11/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Envelope.h"
#import "MDMath.h"
#import <QuartzCore/QuartzCore.h>

#define envCoeffA (0.0485442)
#define envCoeffB (63.185616)

A4TrackerParam_t ADRParamNormalizedToSeconds(A4TrackerParam_t normalizedParamValue) // convert normalised ADR param to seconds
{
	normalizedParamValue = mdmath_clamp(normalizedParamValue, 0, 1);
	normalizedParamValue *= 127;
	A4TrackerParam_t val = (exp(normalizedParamValue * envCoeffA) - 1) * envCoeffB / 1000;
	if(isnan(val))
	{
		DLog(@"NAN!");
	}
	return val;
}

A4TrackerParam_t secondsToNormalizedADRParam(A4TrackerParam_t seconds) // convert seconds to normalized ADR param
{
	if(seconds <= 0) return 0;
	A4TrackerParam_t val = mdmath_clamp(seconds, 0, 30);
	val /= envCoeffB;
	val *= 1000;
	val += 1;
	
	A4TrackerParam_t logval = log(val) / envCoeffA / 127;
	if(isnan(logval))
	{
		DLog(@"NAN!");
	}
	
	return logval;
}

A4TrackerParam_t envLinToExp(A4TrackerParam_t normalizedParamValue) // convert envelope value from LIN to EXP
{
	if(normalizedParamValue <= 0) return 0;
	normalizedParamValue = mdmath_clamp(normalizedParamValue, 0, 1);
	normalizedParamValue *= 127;
	A4TrackerParam_t val = (exp(normalizedParamValue * envCoeffA * .77) - 1) * 4.2 * envCoeffB / 1000;
	if(isnan(val))
	{
		DLog(@"NAN!");
	}
	return val / 30;
}

A4TrackerParam_t envExpToLin(A4TrackerParam_t normalizedParamValue) // convert envelope value from EXP to LIN
{
	if(normalizedParamValue <= 0) return 0;
	normalizedParamValue *= 30;
	A4TrackerParam_t val = mdmath_clamp(normalizedParamValue, 0, 30);
	val /= (envCoeffB * 4.2);
	val *= 1000;
	val += 1;
	
	A4TrackerParam_t logval = log(val) / (envCoeffA * .77) / 127;
	if(isnan(logval))
	{
		DLog(@"NAN!");
	}
	
	return logval;
}

A4TrackerParam_t sustainLog(A4TrackerParam_t normalized) // adjust sustain value
{
	if(normalized == 0) return 0;
	return mdmath_clamp(pow(normalized, 1.1), 0, 1);
}

typedef enum Phase
{
	PhaseIdle,
	PhaseAttack,
	PhaseDecay,
	PhaseSustain,
	PhaseRelease
}
Phase;

#define LUTsize (1024*1024)
static A4TrackerParam_t linToExpLUT[LUTsize];
static A4TrackerParam_t expToLinLUT[LUTsize];
static BOOL didCreateLUTs = NO;

static void CreateLUTs()
{
	if(didCreateLUTs) return;
	didCreateLUTs = YES;
	
	for (int i = 0; i < LUTsize; i++)
	{
		A4TrackerParam_t val = mdmath_map(i, 0, LUTsize-1, 0, 1);
		linToExpLUT[i] = envLinToExp(val);
		expToLinLUT[i] = envExpToLin(val);
	}
}

static A4TrackerParam_t LookupEnvLinToExp(A4TrackerParam_t value)
{
	return linToExpLUT[(int)mdmath_clamp(mdmath_map(value, 0, 1, 0, LUTsize-1), 0, LUTsize-1)];
}

static A4TrackerParam_t LookupEnvExpToLin(A4TrackerParam_t value)
{
	return expToLinLUT[(int)mdmath_clamp(mdmath_map(value, 0, 1, 0, LUTsize-1), 0, LUTsize-1)];
}

@interface A4Envelope()
@property (nonatomic) Phase phase;
@property (nonatomic) A4TrackerParam_t timeAtStartOfAttackPhase;
@property (nonatomic) A4TrackerParam_t timeAtStartOfReleasePhase;
@property (nonatomic) A4TrackerParam_t timeAtStartOfDecayPhase;
@property (nonatomic) A4TrackerParam_t timeAtStartOfSustainPhase;
@property (nonatomic) A4TrackerParam_t durationOfReleasePhase;
@property (nonatomic) A4TrackerParam_t valueAtStartOfAttackPhase;
@property (nonatomic) A4TrackerParam_t valueAtStartOfDecayPhase;
@property (nonatomic) A4TrackerParam_t valueAtStartOfSustainPhase;
@property (nonatomic) A4TrackerParam_t valueAtStartOfReleasePhase;
@property (nonatomic) A4TrackerParam_t currentValue;
@property (nonatomic) BOOL releaseDidStartDuringDecayPhase;

@end

@implementation A4Envelope

- (id)init
{
	if(self = [super init])
	{
		CreateLUTs();
	}
	return self;
}

- (void)setAttackVal:(uint8_t)attack
{
	_attackVal = mdmath_clamp(attack, 0, 127);
}

- (void)setDecayVal:(uint8_t)decay
{
	_decayVal = mdmath_clamp(decay, 0, 127);
}

- (void)setSustain:(uint8_t)sustain
{
	_sustainVal = mdmath_clamp(sustain, 0, 127);
}

- (void)setRelease:(uint8_t)release
{
	_releaseVal = mdmath_clamp(release, 0, 127);
}

- (void)reset
{
	_phase = PhaseIdle;
	_currentValue = 0;
}

- (void)openWithTime:(A4TrackerParam_t)time
{
//	DLog(@"%f", time);
	_isOpen = YES;
	
	
	if(_shape == A4EnvelopeShapeLinLinReset ||
	   _shape == A4EnvelopeShapeLinExpReset ||
	   _shape == A4EnvelopeShapeExpExpReset ||
	   _shape == A4EnvelopeShapeExpLinReset ||
	   _shape == A4EnvelopeShapePrcExpReset ||
	   _shape == A4EnvelopeShapePrcLinReset)
	{
		_valueAtStartOfAttackPhase = 0;
		_currentValue = 0;
	}
	else
	{
		_currentValue = self.normalizedValue;
		_valueAtStartOfAttackPhase = _currentValue;
	}
	
	_phase = PhaseAttack;
	_timeAtStartOfAttackPhase = time;
	_timeAtStartOfDecayPhase = _timeAtStartOfAttackPhase + ADRParamNormalizedToSeconds(_attackVal / 127.0) * (1-_valueAtStartOfAttackPhase);
	_timeAtStartOfSustainPhase = _timeAtStartOfDecayPhase + ADRParamNormalizedToSeconds(_decayVal / 127.0) * (1-sustainLog(_sustainVal/127.0));
}

- (void)closeWithTime:(A4TrackerParam_t)time
{
	_isOpen = NO;
	_timeAtStartOfReleasePhase = time;
	_releaseDidStartDuringDecayPhase = NO;
	
	if (_phase == PhaseDecay || _phase == PhaseAttack)
	{
		_valueAtStartOfReleasePhase = _currentValue;
		
		if((_shape == A4EnvelopeShapePrcExp ||
			   _shape == A4EnvelopeShapePrcExpReset ||
			   _shape == A4EnvelopeShapeExpExp ||
			   _shape == A4EnvelopeShapeExpExpReset ||
			   _shape == A4EnvelopeShapeLinExp ||
			   _shape == A4EnvelopeShapeLinExpReset
			   ))
		{
			_currentValue = _valueAtStartOfReleasePhase;
		}
		else
		{
			_valueAtStartOfReleasePhase = _currentValue;
		}
		
		if(_phase == PhaseAttack)
		{
			if(_shape == A4EnvelopeShapeExpLin ||
			 _shape == A4EnvelopeShapeExpLinReset)
			{
				_currentValue = LookupEnvLinToExp(_currentValue);
				_valueAtStartOfReleasePhase = _currentValue;
			}
			else if (_shape == A4EnvelopeShapeLinExp ||
					 _shape == A4EnvelopeShapeLinExpReset)
			{
				_currentValue = LookupEnvExpToLin(_currentValue);
				_valueAtStartOfReleasePhase = _currentValue;
			}
		}
		   
		
		
//		if(_phase == PhaseDecay && ) _releaseDidStartDuringDecayPhase = YES;
		
//		_valueLogAtStartOfReleasePhase = envLog(_valueAtStartOfReleasePhase);
	}
	else if(_phase == PhaseSustain)
	{
//		DLog(@"SUSTAIN -> RELEASE @ %f", time);
		if((_shape == A4EnvelopeShapePrcExp ||
			_shape == A4EnvelopeShapePrcExpReset ||
			_shape == A4EnvelopeShapeExpExp ||
			_shape == A4EnvelopeShapeExpExpReset ||
			_shape == A4EnvelopeShapeLinExp ||
			_shape == A4EnvelopeShapeLinExpReset
			))
		{
			_currentValue = _valueAtStartOfReleasePhase;
		}
		else
		{
			_valueAtStartOfReleasePhase = sustainLog(_sustainVal/127.0);
		}
	}
	
	
	_phase = PhaseRelease;
	
	if(_shape == A4EnvelopeShapePrcExp ||
	   _shape == A4EnvelopeShapePrcExpReset ||
	   _shape == A4EnvelopeShapeExpExp ||
	   _shape == A4EnvelopeShapeExpExpReset ||
	   _shape == A4EnvelopeShapeLinExp ||
	   _shape == A4EnvelopeShapeLinExpReset
	   )
	{
		_durationOfReleasePhase = (_valueAtStartOfReleasePhase) * ADRParamNormalizedToSeconds(_releaseVal/127.0);
	}
	else
	{
		_durationOfReleasePhase = (_valueAtStartOfReleasePhase) * ADRParamNormalizedToSeconds(_releaseVal/127.0);
	}
}

- (void)updateWithTime:(A4TrackerParam_t)time
{
//	DLog(@"%f", time);
	
	if(_phase == PhaseAttack && time >= _timeAtStartOfDecayPhase)
	{
		_currentValue = 1;
		_valueAtStartOfDecayPhase = _currentValue;
		_phase = PhaseDecay;
//		DLog(@"ATTACK -> DECAY @ %f", time);
	}
	
	if(_phase == PhaseDecay && time >= _timeAtStartOfSustainPhase)
	{
		_phase = PhaseSustain;
		_currentValue = sustainLog(_sustainVal/127.0);
//		DLog(@"DECAY -> SUSTAIN @ %f", time);
		
		if(isnan(_currentValue))
		{
			DLog(@"NAN!");
		}
	}
	
	if(_phase == PhaseDecay)
	{
		if(_shape == A4EnvelopeShapePrcExp ||
		   _shape == A4EnvelopeShapePrcExpReset ||
		   _shape == A4EnvelopeShapeExpExp ||
		   _shape == A4EnvelopeShapeExpExpReset ||
		   _shape == A4EnvelopeShapeLinExp ||
		   _shape == A4EnvelopeShapeLinExpReset
		   )
		{
			if(LookupEnvLinToExp(_currentValue) <= sustainLog(_sustainVal/127.0))
			{
				_valueAtStartOfReleasePhase = _currentValue;
				_valueAtStartOfSustainPhase = _currentValue;
				_phase = PhaseSustain;
//				DLog(@"---> SUSTAIN");
//				_currentValue = sustainLog(_sustainVal/127.0);
			}
		}
	}
	
	switch (_phase)
	{
		case PhaseAttack:
		{
			A4TrackerParam_t timeDeltaSinceAttackStart = time - _timeAtStartOfAttackPhase;
			A4TrackerParam_t durationOfAttackPhase = _timeAtStartOfDecayPhase - _timeAtStartOfAttackPhase;
			_currentValue = mdmath_clamp(mdmath_map(timeDeltaSinceAttackStart, 0, durationOfAttackPhase, _valueAtStartOfAttackPhase, 1), 0, 1);
			
			if(isnan(_currentValue))
			{
				DLog(@"NAN!");
			}
			break;
		}
		case PhaseDecay:
		{
			A4TrackerParam_t timeDeltaSinceDecayStart = time - _timeAtStartOfDecayPhase;
			A4TrackerParam_t durationOfDecayPhase = _timeAtStartOfSustainPhase - _timeAtStartOfDecayPhase;
			_currentValue = mdmath_clamp(mdmath_map(timeDeltaSinceDecayStart, 0, durationOfDecayPhase,
										  _valueAtStartOfDecayPhase, sustainLog(_sustainVal/127.0)), 0, 1);
			
			if(isnan(_currentValue))
			{
				DLog(@"NAN!");
			}
			
			break;
		}
		case PhaseSustain:
		{
			_currentValue = sustainLog(_sustainVal/127.0);
			if(isnan(_currentValue))
			{
				DLog(@"NAN!");
			}
			break;
		}
		case PhaseRelease:
		{
			if(_releaseVal == 127) break;
			A4TrackerParam_t timeDeltaSinceReleaseStart = time - _timeAtStartOfReleasePhase;
			if(_durationOfReleasePhase == 0 || _valueAtStartOfReleasePhase == 0)
			{
				_currentValue = 0;
				_phase = PhaseIdle;
			}
			else
			{
				_currentValue = mdmath_clamp( mdmath_map(timeDeltaSinceReleaseStart, 0,
														 _durationOfReleasePhase,
														 _valueAtStartOfReleasePhase, 0), 0, 1);
			}
			
			if(isnan(_currentValue))
			{
				DLog(@"NAN!");
			}
			
			break;
		}
		default:
		{
			_currentValue = 0;
			break;
		}
	}
}

- (A4TrackerParam_t) normalizedValue
{
	switch (_phase)
	{
		case PhaseAttack:
		{
			if(_shape == A4EnvelopeShapePrcExp ||
			   _shape == A4EnvelopeShapePrcExpReset ||
			   _shape == A4EnvelopeShapePrcLin ||
			   _shape == A4EnvelopeShapePrcLinReset)
			{
				return 1;
			}
			else if(_shape == A4EnvelopeShapeExpExp ||
					_shape == A4EnvelopeShapeExpExpReset ||
					_shape == A4EnvelopeShapeExpLin ||
					_shape == A4EnvelopeShapeExpLinReset)
			{
				return mdmath_clamp(LookupEnvLinToExp(_currentValue), 0, 1);
			}
			return mdmath_clamp(_currentValue, 0, 1);
			break;
		}
		case PhaseDecay:
		{
			if(_shape == A4EnvelopeShapePrcExp ||
			   _shape == A4EnvelopeShapePrcExpReset ||
			   _shape == A4EnvelopeShapeExpExp ||
			   _shape == A4EnvelopeShapeExpExpReset ||
			   _shape == A4EnvelopeShapeLinExp ||
			   _shape == A4EnvelopeShapeLinExpReset
			   )
			{
				return mdmath_clamp(LookupEnvLinToExp(_currentValue), 0, 1);
			}
			else
			{
				return mdmath_clamp(_currentValue, 0, 1);
			}
		}
		case PhaseSustain:
		{
			return mdmath_clamp(sustainLog(_sustainVal/127.0), 0, 1);
		}
		case PhaseRelease:
		{
			if(_shape == A4EnvelopeShapePrcExp ||
			   _shape == A4EnvelopeShapePrcExpReset ||
			   _shape == A4EnvelopeShapeExpExp ||
			   _shape == A4EnvelopeShapeExpExpReset ||
			   _shape == A4EnvelopeShapeLinExp ||
			   _shape == A4EnvelopeShapeLinExpReset
			   )
			{
					return mdmath_clamp(LookupEnvLinToExp(_currentValue), 0, 1);

			}
			else
			{
				return mdmath_clamp(_currentValue, 0, 1);
			}
		}
		default:
			break;
	}
	return 0;
}

@end
