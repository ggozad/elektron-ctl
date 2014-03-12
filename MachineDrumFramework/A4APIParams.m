//
//  A4APIParams.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/03/14.
//  Copyright (c) 2014 Jakob Penca. All rights reserved.
//

#import "A4APIParams.h"
#import "A4Request.h"
#import "A4Kit.h"
#import "A4Sound.h"

@implementation A4APIParams

+ (void) executeSetTrackSoundParamWithTrackIterator:(A4APIStringNumericIterator *) trackIt
											   args:(NSArray *)args
									   onCompletion:(void (^)(NSString *))completionHandler
											onError:(void (^)(NSString *))errorHandler
{
	if(!trackIt.isValid)
	{
		errorHandler(@"INVALID TRACK");
		return;
	}
	
	uint8_t trackIdx = [trackIt currentValue] - 1;
	
	if(trackIdx > 4)
	{
		errorHandler(@"INVALID TRACK");
		return;
	}
	
	if(args.count < 3)
	{
		errorHandler(@"INVALID ARGS");
		return;
	}
	
	NSArray *paramArgs = [args subarrayWithRange:NSMakeRange(0, 2)];
	A4Param param;
	
	if(trackIdx < 4) param = [self synthParamWithArgs:paramArgs];
	else param = [self fxParamWithArgs:paramArgs];
	
	
	if(param == A4NULL)
	{
		errorHandler(@"INVALID PARAM");
		return;
	}
	
	double min = trackIdx == 4 ? A4ParamFxMin(param) : A4ParamMin(param);
	double max = trackIdx == 4 ? A4ParamFxMax(param) : A4ParamMax(param);
	
	A4APIStringNumericIterator *it = nil;
	double paramValue = A4NULL;
	uint8_t paramValueTarget = A4NULL;
	
	if(trackIdx < 4 && A4ParamIsModulatorDestination(param))
	{
		if(args.count >= 4)
		{
			NSArray *targetArgs = [args subarrayWithRange:NSMakeRange(2, args.count - 2)];
			A4Param target = [self synthParamWithArgs:targetArgs];
			if(target != A4NULL)
			{
				if((param == A4PARAMS_ENV1.DESTINATION_A ||
				   param == A4PARAMS_ENV1.DESTINATION_B) &&
				   A4ParamIsEnv1Target(target))
				{
					paramValueTarget = target;
				}
				if((param == A4PARAMS_ENV2.DESTINATION_A ||
					param == A4PARAMS_ENV2.DESTINATION_B) &&
				   A4ParamIsEnv2Target(target))
				{
					paramValueTarget = target;
				}
				if((param == A4PARAMS_LFO1.DESTINATION_A ||
					param == A4PARAMS_LFO1.DESTINATION_B) &&
				   A4ParamIsLfo1Target(target))
				{
					paramValueTarget = target;
				}
				if((param == A4PARAMS_LFO2.DESTINATION_A ||
					param == A4PARAMS_LFO2.DESTINATION_B) &&
				   A4ParamIsLfo2Target(target))
				{
					paramValueTarget = target;
				}
			}
		}
		else
		{
			it = [A4APIStringNumericIterator iteratorWithStringToken:args[2]
															   range:A4ApiIteratorRangeMake(min, max)
																mode:A4ApiIteratorRangeModeWrap
															   inVal:A4ParamIs16Bit(param) ? A4ApiIteratorInputValFloat : A4ApiIteratorInputValInt
															  retVal:A4ParamIs16Bit(param) ? A4ApiIteratorReturnValFloat : A4ApiIteratorReturnValInt];
			if(it.isValid)
			{
				uint8_t tgtIdx = [it currentValue];
				A4Param tgt = A4ParamModTargetByIndexInModSource(param, tgtIdx);
				if(tgt != A4NULL) paramValueTarget = tgt;

			}
		}
	}
	else
	{
		it = [A4APIStringNumericIterator iteratorWithStringToken:args[2]
														   range:A4ApiIteratorRangeMake(min, max)
															mode:A4ApiIteratorRangeModeWrap
														   inVal:A4ParamIs16Bit(param) ? A4ApiIteratorInputValFloat : A4ApiIteratorInputValInt
														  retVal:A4ParamIs16Bit(param) ? A4ApiIteratorReturnValFloat : A4ApiIteratorReturnValInt];
		if(it.isValid)
		{
			paramValue = [it currentValue];
		}
	}
	
	if(paramValue == A4NULL && paramValueTarget == A4NULL)
	{
		errorHandler(@"DUNNO LOL");
		return;
	}
	
	A4PVal pval = A4PValMakeInvalid();
	if(paramValueTarget != A4NULL)
		pval = trackIdx < 4 ? A4PValMake8(param, paramValueTarget) : A4PValFxMake16(param, paramValueTarget, 0);
	else
		pval = trackIdx < 4 ? A4PValMake(param, paramValue) : A4PValFxMake16(param, (u_int8_t) paramValue, 0);
	
	[A4Request requestWithKeys:@[@"kit.x"]
			 completionHandler:^(NSDictionary *dict) {
				 
				 A4Kit *kit = dict[@"kit.x"];
				 if(trackIdx < 4)
				 {
					 A4Sound *sound = [kit soundAtTrack:trackIdx copy:NO];
					 [sound setParamValue:pval];
				 }
				 else
				 {
					 [kit setFxParamValue:pval];
				 }
				 
				 [kit sendTemp];
				 
				 NSString *str = [NSString stringWithFormat:@"TRACK %d PARAM 0X%02X VALUE 0X%02X", trackIdx + 1, pval.param, pval.coarse];
				 completionHandler(str);
				 
			 } errorHandler:^(NSError *err) {
				 
				 errorHandler(err.description);
				 
			 }];
	
	
}


+ (A4Param)synthParamWithArgs:(NSArray *)args
{
	if(!args || args.count != 2) return A4NULL;

	if([args[0] isEqualToString:@"OSC1"] || [args[0] isEqualToString:@"OSCILLATOR1"])
	{
		if([args[1] isEqualToString:@"TUNE"] || [args[1] isEqualToString:@"TUN"])		return A4PARAMS_OSC1.TUNING;
		if([args[1] isEqualToString:@"DETUNE"] || [args[1] isEqualToString:@"DET"])		return A4PARAMS_OSC1.DETUNING;
		if([args[1] isEqualToString:@"KEYTRACK"] ||[args[1] isEqualToString:@"TRK"])	return A4PARAMS_OSC1.KEYTRACK;
		if([args[1] isEqualToString:@"TUNE"] || [args[1] isEqualToString:@"TUN"])		return A4PARAMS_OSC1.TUNING;
		if([args[1] isEqualToString:@"LEVEL"] || [args[1] isEqualToString:@"LEV"])		return A4PARAMS_OSC1.LEVEL;
		if([args[1] isEqualToString:@"WAVEFORM"] || [args[1] isEqualToString:@"WAV"])		return A4PARAMS_OSC1.WAVEFORM;
		if([args[1] isEqualToString:@"SUBOSCILLATOR"] || [args[1] isEqualToString:@"SUB"])	return A4PARAMS_OSC1.SUBOSCILLATOR;
		if([args[1] isEqualToString:@"PULSEWIDTH"] || [args[1] isEqualToString:@"PW"])	return A4PARAMS_OSC1.PULSEWIDTH;
		if([args[1] isEqualToString:@"PWMSPEED"] || [args[1] isEqualToString:@"SPD"])	return A4PARAMS_OSC1.PWM_SPEED;
		if([args[1] isEqualToString:@"PWMDEPTH"] || [args[1] isEqualToString:@"PWM"])	return A4PARAMS_OSC1.PWM_DEPTH;
	}
	else if([args[0] isEqualToString:@"OSC2"] || [args[0] isEqualToString:@"OSCILLATOR2"])
	{
		if([args[1] isEqualToString:@"TUNE"] || [args[1] isEqualToString:@"TUN"])		return A4PARAMS_OSC2.TUNING;
		if([args[1] isEqualToString:@"DETUNE"] || [args[1] isEqualToString:@"DET"])		return A4PARAMS_OSC2.DETUNING;
		if([args[1] isEqualToString:@"KEYTRACK"] ||[args[1] isEqualToString:@"TRK"])	return A4PARAMS_OSC2.KEYTRACK;
		if([args[1] isEqualToString:@"TUNE"] || [args[1] isEqualToString:@"TUN"])		return A4PARAMS_OSC2.TUNING;
		if([args[1] isEqualToString:@"LEVEL"] || [args[1] isEqualToString:@"LEV"])		return A4PARAMS_OSC2.LEVEL;
		if([args[1] isEqualToString:@"WAVEFORM"] || [args[1] isEqualToString:@"WAV"])		return A4PARAMS_OSC2.WAVEFORM;
		if([args[1] isEqualToString:@"SUBOSCILLATOR"] || [args[1] isEqualToString:@"SUB"])	return A4PARAMS_OSC2.SUBOSCILLATOR;
		if([args[1] isEqualToString:@"PULSEWIDTH"] || [args[1] isEqualToString:@"PW"])	return A4PARAMS_OSC2.PULSEWIDTH;
		if([args[1] isEqualToString:@"PWMSPEED"] || [args[1] isEqualToString:@"SPD"])	return A4PARAMS_OSC2.PWM_SPEED;
		if([args[1] isEqualToString:@"PWMDEPTH"] || [args[1] isEqualToString:@"PWM"])	return A4PARAMS_OSC2.PWM_DEPTH;
	}
	else if([args[0] isEqualToString:@"NOIS"] || [args[0] isEqualToString:@"NOISE"])
	{
		if([args[1] isEqualToString:@"SAMPLEHOLD"] || [args[1] isEqualToString:@"SH"])	return A4PARAMS_NOIS.SAMPLEHOLD;
		if([args[1] isEqualToString:@"FADE"] || [args[1] isEqualToString:@"FAD"])		return A4PARAMS_NOIS.FADE;
		if([args[1] isEqualToString:@"LEVEL"] || [args[1] isEqualToString:@"LEV"])		return A4PARAMS_NOIS.LEVEL;
	}
	else if([args[0] isEqualToString:@"OSC"] || [args[0] isEqualToString:@"OSCCOMMON"])
	{
		if([args[1] isEqualToString:@"AM1"])											return A4PARAMS_OSC.AM1;
		if([args[1] isEqualToString:@"AM2"])											return A4PARAMS_OSC.AM2;
		if([args[1] isEqualToString:@"SMD"] || [args[1] isEqualToString:@"SYNCMODE"])	return A4PARAMS_OSC.SYNC_MODE;
		if([args[1] isEqualToString:@"SNC"] || [args[1] isEqualToString:@"SYNCAMOUNT"])	return A4PARAMS_OSC.SYNC_AMOUNT;
		if([args[1] isEqualToString:@"BND"] || [args[1] isEqualToString:@"BENDDEPTH"])	return A4PARAMS_OSC.BENDDEPTH;
		if([args[1] isEqualToString:@"SLI"] || [args[1] isEqualToString:@"SLIDETIME"])	return A4PARAMS_OSC.SLIDETIME;
		if([args[1] isEqualToString:@"TRG"] || [args[1] isEqualToString:@"RETRIG"])		return A4PARAMS_OSC.RETRIG;
		if([args[1] isEqualToString:@"FAD"] || [args[1] isEqualToString:@"VIBRATOFADE"])	return A4PARAMS_OSC.VIBRATO_FADE;
		if([args[1] isEqualToString:@"SPD"] || [args[1] isEqualToString:@"VIBRATOSPEED"])	return A4PARAMS_OSC.VIBRATO_SPEED;
		if([args[1] isEqualToString:@"VIB"] || [args[1] isEqualToString:@"VIBRATODEPTH"])	return A4PARAMS_OSC.VIBRATO_DEPTH;
	}
	else if([args[0] isEqualToString:@"FIL1"] || [args[0] isEqualToString:@"FILTER1"])
	{
		if([args[1] isEqualToString:@"FRQ"] || [args[1] isEqualToString:@"FREQUENCY"])	return A4PARAMS_FILT.F1_FREQUENCY;
		if([args[1] isEqualToString:@"RES"] || [args[1] isEqualToString:@"RESONANCE"])	return A4PARAMS_FILT.F1_RESONANCE;
		if([args[1] isEqualToString:@"OVR"] || [args[1] isEqualToString:@"OVERDRIVE"])	return A4PARAMS_FILT.F1_OVERDRIVE;
		if([args[1] isEqualToString:@"TRK"] || [args[1] isEqualToString:@"KEYTRACK"])	return A4PARAMS_FILT.F1_KEYTRACK;
		if([args[1] isEqualToString:@"DEP"] || [args[1] isEqualToString:@"MODDEPTH"])	return A4PARAMS_FILT.F1_MODDEPTH;
	}
	else if([args[0] isEqualToString:@"FIL2"] || [args[0] isEqualToString:@"FILTER2"])
	{
		if([args[1] isEqualToString:@"FRQ"] || [args[1] isEqualToString:@"FREQUENCY"])	return A4PARAMS_FILT.F2_FREQUENCY;
		if([args[1] isEqualToString:@"RES"] || [args[1] isEqualToString:@"RESONANCE"])	return A4PARAMS_FILT.F2_RESONANCE;
		if([args[1] isEqualToString:@"TYP"] || [args[1] isEqualToString:@"TYPE"])		return A4PARAMS_FILT.F2_TYPE;
		if([args[1] isEqualToString:@"TRK"] || [args[1] isEqualToString:@"KEYTRACK"])	return A4PARAMS_FILT.F2_KEYTRACK;
		if([args[1] isEqualToString:@"DEP"] || [args[1] isEqualToString:@"MODDEPTH"])	return A4PARAMS_FILT.F2_MODDEPTH;
	}
	else if([args[0] isEqualToString:@"AMP"] || [args[0] isEqualToString:@"AMPLIFIER"])
	{
		if([args[1] isEqualToString:@"ATK"] || [args[1] isEqualToString:@"ATTACK"])		return A4PARAMS_AMP.ENV_ATTACK;
		if([args[1] isEqualToString:@"DEC"] || [args[1] isEqualToString:@"DECAY"])		return A4PARAMS_AMP.ENV_DECAY;
		if([args[1] isEqualToString:@"SUS"] || [args[1] isEqualToString:@"SUSTAIN"])	return A4PARAMS_AMP.ENV_SUSTAIN;
		if([args[1] isEqualToString:@"REL"] || [args[1] isEqualToString:@"RELEASE"])	return A4PARAMS_AMP.ENV_RELEASE;
		if([args[1] isEqualToString:@"SHP"] || [args[1] isEqualToString:@"SHAPE"])		return A4PARAMS_AMP.SHAPE;
		if([args[1] isEqualToString:@"CHO"] || [args[1] isEqualToString:@"CHORUS"])		return A4PARAMS_AMP.SEND_CHORUS;
		if([args[1] isEqualToString:@"DEL"] || [args[1] isEqualToString:@"DELAY"])		return A4PARAMS_AMP.SEND_DELAY;
		if([args[1] isEqualToString:@"REV"] || [args[1] isEqualToString:@"REVERB"])		return A4PARAMS_AMP.SEND_REVERB;
		if([args[1] isEqualToString:@"PAN"] || [args[1] isEqualToString:@"PANNING"])	return A4PARAMS_AMP.PANNING;
		if([args[1] isEqualToString:@"VOL"] || [args[1] isEqualToString:@"VOLUME"])		return A4PARAMS_AMP.VOLUME;
	}
	else if([args[0] isEqualToString:@"ENV1"] || [args[0] isEqualToString:@"ENVELOPE1"])
	{
		if([args[1] isEqualToString:@"ATK"] || [args[1] isEqualToString:@"ATTACK"])		return A4PARAMS_ENV1.ENV_ATTACK;
		if([args[1] isEqualToString:@"DEC"] || [args[1] isEqualToString:@"DECAY"])		return A4PARAMS_ENV1.ENV_DECAY;
		if([args[1] isEqualToString:@"SUS"] || [args[1] isEqualToString:@"SUSTAIN"])	return A4PARAMS_ENV1.ENV_SUSTAIN;
		if([args[1] isEqualToString:@"REL"] || [args[1] isEqualToString:@"RELEASE"])	return A4PARAMS_ENV1.ENV_RELEASE;
		if([args[1] isEqualToString:@"SHP"] || [args[1] isEqualToString:@"SHAPE"])		return A4PARAMS_ENV1.SHAPE;
		if([args[1] isEqualToString:@"LEN"] || [args[1] isEqualToString:@"GATELENGTH"])	return A4PARAMS_ENV1.GATELENGTH;
		if([args[1] isEqualToString:@"TGTA"] || [args[1] isEqualToString:@"TARGETA"])	return A4PARAMS_ENV1.DESTINATION_A;
		if([args[1] isEqualToString:@"TGTB"] || [args[1] isEqualToString:@"TARGETB"])	return A4PARAMS_ENV1.DESTINATION_B;
		if([args[1] isEqualToString:@"DEPA"] || [args[1] isEqualToString:@"DEPTHA"])	return A4PARAMS_ENV1.DEPTH_A;
		if([args[1] isEqualToString:@"DEPB"] || [args[1] isEqualToString:@"DEPTHB"])	return A4PARAMS_ENV1.DEPTH_B;
	}
	else if([args[0] isEqualToString:@"ENV2"] || [args[0] isEqualToString:@"ENVELOPE2"])
	{
		if([args[1] isEqualToString:@"ATK"] || [args[1] isEqualToString:@"ATTACK"])		return A4PARAMS_ENV2.ENV_ATTACK;
		if([args[1] isEqualToString:@"DEC"] || [args[1] isEqualToString:@"DECAY"])		return A4PARAMS_ENV2.ENV_DECAY;
		if([args[1] isEqualToString:@"SUS"] || [args[1] isEqualToString:@"SUSTAIN"])	return A4PARAMS_ENV2.ENV_SUSTAIN;
		if([args[1] isEqualToString:@"REL"] || [args[1] isEqualToString:@"RELEASE"])	return A4PARAMS_ENV2.ENV_RELEASE;
		if([args[1] isEqualToString:@"SHP"] || [args[1] isEqualToString:@"SHAPE"])		return A4PARAMS_ENV2.SHAPE;
		if([args[1] isEqualToString:@"LEN"] || [args[1] isEqualToString:@"GATELENGTH"])	return A4PARAMS_ENV2.GATELENGTH;
		if([args[1] isEqualToString:@"TGTA"] || [args[1] isEqualToString:@"TARGETA"])	return A4PARAMS_ENV2.DESTINATION_A;
		if([args[1] isEqualToString:@"TGTB"] || [args[1] isEqualToString:@"TARGETB"])	return A4PARAMS_ENV2.DESTINATION_B;
		if([args[1] isEqualToString:@"DEPA"] || [args[1] isEqualToString:@"DEPTHA"])	return A4PARAMS_ENV2.DEPTH_A;
		if([args[1] isEqualToString:@"DEPB"] || [args[1] isEqualToString:@"DEPTHB"])	return A4PARAMS_ENV2.DEPTH_B;
	}
	else if([args[0] isEqualToString:@"LFO1"])
	{
		if([args[1] isEqualToString:@"SPD"] || [args[1] isEqualToString:@"SPEED"])		return A4PARAMS_LFO1.SPEED;
		if([args[1] isEqualToString:@"MUL"] || [args[1] isEqualToString:@"MULTIPLIER"])	return A4PARAMS_LFO1.MULTIPLIER;
		if([args[1] isEqualToString:@"FAD"] || [args[1] isEqualToString:@"FADE"])		return A4PARAMS_LFO1.FADE;
		if([args[1] isEqualToString:@"SPH"] || [args[1] isEqualToString:@"STARTPHASE"])	return A4PARAMS_LFO1.STARTPHASE;
		if([args[1] isEqualToString:@"MOD"] || [args[1] isEqualToString:@"MODE"])		return A4PARAMS_LFO1.MODE;
		if([args[1] isEqualToString:@"WAV"] || [args[1] isEqualToString:@"WAVEFORM"])	return A4PARAMS_LFO1.WAVEFORM;
		if([args[1] isEqualToString:@"TGTA"] || [args[1] isEqualToString:@"TARGETA"])	return A4PARAMS_LFO1.DESTINATION_A;
		if([args[1] isEqualToString:@"TGTB"] || [args[1] isEqualToString:@"TARGETB"])	return A4PARAMS_LFO1.DESTINATION_B;
		if([args[1] isEqualToString:@"DEPA"] || [args[1] isEqualToString:@"DEPTHA"])	return A4PARAMS_LFO1.DEPTH_A;
		if([args[1] isEqualToString:@"DEPB"] || [args[1] isEqualToString:@"DEPTHB"])	return A4PARAMS_LFO1.DEPTH_B;
	}
	else if([args[0] isEqualToString:@"LFO2"])
	{
		if([args[1] isEqualToString:@"SPD"] || [args[1] isEqualToString:@"SPEED"])		return A4PARAMS_LFO2.SPEED;
		if([args[1] isEqualToString:@"MUL"] || [args[1] isEqualToString:@"MULTIPLIER"])	return A4PARAMS_LFO2.MULTIPLIER;
		if([args[1] isEqualToString:@"FAD"] || [args[1] isEqualToString:@"FADE"])		return A4PARAMS_LFO2.FADE;
		if([args[1] isEqualToString:@"SPH"] || [args[1] isEqualToString:@"STARTPHASE"])	return A4PARAMS_LFO2.STARTPHASE;
		if([args[1] isEqualToString:@"MOD"] || [args[1] isEqualToString:@"MODE"])		return A4PARAMS_LFO2.MODE;
		if([args[1] isEqualToString:@"WAV"] || [args[1] isEqualToString:@"WAVEFORM"])	return A4PARAMS_LFO2.WAVEFORM;
		if([args[1] isEqualToString:@"TGTA"] || [args[1] isEqualToString:@"TARGETA"])	return A4PARAMS_LFO2.DESTINATION_A;
		if([args[1] isEqualToString:@"TGTB"] || [args[1] isEqualToString:@"TARGETB"])	return A4PARAMS_LFO2.DESTINATION_B;
		if([args[1] isEqualToString:@"DEPA"] || [args[1] isEqualToString:@"DEPTHA"])	return A4PARAMS_LFO2.DEPTH_A;
		if([args[1] isEqualToString:@"DEPB"] || [args[1] isEqualToString:@"DEPTHB"])	return A4PARAMS_LFO2.DEPTH_B;
	}
	
	return A4NULL;
}

+ (A4Param)fxParamWithArgs:(NSArray *)args
{
	if(!args || args.count != 2) return A4NULL;
	
	if([args[0] isEqualToString:@"EXT"])
	{
		if([args[1] isEqualToString:@"CHORUSL"] || [args[1] isEqualToString:@"CHOL"])	return A4PARAMS_FX_EXT.L_CHORUS;
		if([args[1] isEqualToString:@"CHORUSR"] || [args[1] isEqualToString:@"CHOR"])	return A4PARAMS_FX_EXT.R_CHORUS;
		if([args[1] isEqualToString:@"DELAYL"] || [args[1] isEqualToString:@"DELL"])	return A4PARAMS_FX_EXT.L_DELAY;
		if([args[1] isEqualToString:@"DELAYR"] || [args[1] isEqualToString:@"DELR"])	return A4PARAMS_FX_EXT.R_DELAY;
		if([args[1] isEqualToString:@"REVERBL"] || [args[1] isEqualToString:@"REVL"])	return A4PARAMS_FX_EXT.L_REVERB;
		if([args[1] isEqualToString:@"REVERBR"] || [args[1] isEqualToString:@"REVR"])	return A4PARAMS_FX_EXT.R_REVERB;
	}
	else if([args[0] isEqualToString:@"CHOR"] || [args[0] isEqualToString:@"CHORUS"])
	{
		if([args[1] isEqualToString:@"PREDELAY"] || [args[1] isEqualToString:@"PRE"])	return A4PARAMS_FX_CHOR.PREDELAY;
		if([args[1] isEqualToString:@"SPEED"]	 ||	[args[1] isEqualToString:@"SPD"])	return A4PARAMS_FX_CHOR.SPEED;
		if([args[1] isEqualToString:@"DEPTH"]	 || [args[1] isEqualToString:@"DEP"])	return A4PARAMS_FX_CHOR.DEPTH;
		if([args[1] isEqualToString:@"WIDTH"]	 || [args[1] isEqualToString:@"WID"])	return A4PARAMS_FX_CHOR.WIDTH;
		if([args[1] isEqualToString:@"FEEDBACK"] || [args[1] isEqualToString:@"FDB"])	return A4PARAMS_FX_CHOR.FEEDBACK;
		if([args[1] isEqualToString:@"HIGHPASS"] || [args[1] isEqualToString:@"HPF"])	return A4PARAMS_FX_CHOR.HIGHPASS;
		if([args[1] isEqualToString:@"LOWPASS"]  || [args[1] isEqualToString:@"LPF"])	return A4PARAMS_FX_CHOR.LOWPASS;
		if([args[1] isEqualToString:@"DELAY"]    || [args[1] isEqualToString:@"DEL"])	return A4PARAMS_FX_CHOR.SEND_DELAY;
		if([args[1] isEqualToString:@"REVERB"]   || [args[1] isEqualToString:@"REV"])	return A4PARAMS_FX_CHOR.SEND_REVERB;
		if([args[1] isEqualToString:@"VOLUME"]   || [args[1] isEqualToString:@"VOL"])	return A4PARAMS_FX_CHOR.VOLUME;
	}
	else if([args[0] isEqualToString:@"DEL"] || [args[0] isEqualToString:@"DELAY"])
	{
		if([args[1] isEqualToString:@"TIME"]	|| [args[1] isEqualToString:@"TIM"])	return A4PARAMS_FX_DELAY.TIME;
		if([args[1] isEqualToString:@"X"])												return A4PARAMS_FX_DELAY.PINGPONG;
		if([args[1] isEqualToString:@"WIDTH"]	|| [args[1] isEqualToString:@"WID"])	return A4PARAMS_FX_DELAY.WIDTH;
		if([args[1] isEqualToString:@"FEEDBACK"]|| [args[1] isEqualToString:@"FDB"])	return A4PARAMS_FX_DELAY.FEEDBACK;
		if([args[1] isEqualToString:@"HIGHPASS"]|| [args[1] isEqualToString:@"HPF"])	return A4PARAMS_FX_DELAY.HIGHPASS;
		if([args[1] isEqualToString:@"LOWPASS"]|| [args[1] isEqualToString:@"LPF"])		return A4PARAMS_FX_DELAY.LOWPASS;
		if([args[1] isEqualToString:@"PVERDRIVE"]|| [args[1] isEqualToString:@"OVR"])	return A4PARAMS_FX_DELAY.OVERDRIVE;
		if([args[1] isEqualToString:@"REVERB"]|| [args[1] isEqualToString:@"REV"])		return A4PARAMS_FX_DELAY.SEND_REVERB;
		if([args[1] isEqualToString:@"VOLUME"]|| [args[1] isEqualToString:@"VOL"])		return A4PARAMS_FX_DELAY.VOLUME;
	}
	else if([args[0] isEqualToString:@"REV"] || [args[0] isEqualToString:@"REVERB"])
	{
		if([args[1] isEqualToString:@"PREDELAY"]	|| [args[1] isEqualToString:@"PRE"])	return A4PARAMS_FX_REVERB.PREDELAY;
		if([args[1] isEqualToString:@"DECAY"]		|| [args[1] isEqualToString:@"DEC"])	return A4PARAMS_FX_REVERB.DECAY;
		if([args[1] isEqualToString:@"FREQUENCY"]	|| [args[1] isEqualToString:@"FRQ"])	return A4PARAMS_FX_REVERB.SHELV_FREQUENCY;
		if([args[1] isEqualToString:@"GAIN"]	    || [args[1] isEqualToString:@"GAI"])	return A4PARAMS_FX_REVERB.SHELV_GAIN;
		if([args[1] isEqualToString:@"HIGHPASS"]	|| [args[1] isEqualToString:@"HPF"])	return A4PARAMS_FX_REVERB.HIGHPASS;
		if([args[1] isEqualToString:@"LOWPASS"]	|| [args[1] isEqualToString:@"LPF"])		return A4PARAMS_FX_REVERB.LOWPASS;
		if([args[1] isEqualToString:@"VOLUME"]	|| [args[1] isEqualToString:@"VOL"])		return A4PARAMS_FX_REVERB.VOLUME;
	}
	else if([args[0] isEqualToString:@"LFO1"])
	{
		if([args[1] isEqualToString:@"SPD"] || [args[1] isEqualToString:@"SPEED"])		return A4PARAMS_FX_LFO1.SPEED;
		if([args[1] isEqualToString:@"MUL"] || [args[1] isEqualToString:@"MULTIPLIER"])	return A4PARAMS_FX_LFO1.MULTIPLIER;
		if([args[1] isEqualToString:@"FAD"] || [args[1] isEqualToString:@"FADE"])		return A4PARAMS_FX_LFO1.FADE;
		if([args[1] isEqualToString:@"SPH"] || [args[1] isEqualToString:@"STARTPHASE"])	return A4PARAMS_FX_LFO1.STARTPHASE;
		if([args[1] isEqualToString:@"MOD"] || [args[1] isEqualToString:@"MODE"])		return A4PARAMS_FX_LFO1.MODE;
		if([args[1] isEqualToString:@"WAV"] || [args[1] isEqualToString:@"WAVEFORM"])	return A4PARAMS_FX_LFO1.WAVEFORM;
		if([args[1] isEqualToString:@"TGTA"] || [args[1] isEqualToString:@"TARGETA"])	return A4PARAMS_FX_LFO1.DESTINATION_A;
		if([args[1] isEqualToString:@"TGTB"] || [args[1] isEqualToString:@"TARGETB"])	return A4PARAMS_FX_LFO1.DESTINATION_B;
		if([args[1] isEqualToString:@"DEPA"] || [args[1] isEqualToString:@"DEPTHA"])	return A4PARAMS_FX_LFO1.DEPTH_A;
		if([args[1] isEqualToString:@"DEPB"] || [args[1] isEqualToString:@"DEPTHB"])	return A4PARAMS_FX_LFO1.DEPTH_B;
	}
	else if([args[0] isEqualToString:@"LFO2"])
	{
		if([args[1] isEqualToString:@"SPD"] || [args[1] isEqualToString:@"SPEED"])		return A4PARAMS_FX_LFO2.SPEED;
		if([args[1] isEqualToString:@"MUL"] || [args[1] isEqualToString:@"MULTIPLIER"])	return A4PARAMS_FX_LFO2.MULTIPLIER;
		if([args[1] isEqualToString:@"FAD"] || [args[1] isEqualToString:@"FADE"])		return A4PARAMS_FX_LFO2.FADE;
		if([args[1] isEqualToString:@"SPH"] || [args[1] isEqualToString:@"STARTPHASE"])	return A4PARAMS_FX_LFO2.STARTPHASE;
		if([args[1] isEqualToString:@"MOD"] || [args[1] isEqualToString:@"MODE"])		return A4PARAMS_FX_LFO2.MODE;
		if([args[1] isEqualToString:@"WAV"] || [args[1] isEqualToString:@"WAVEFORM"])	return A4PARAMS_FX_LFO2.WAVEFORM;
		if([args[1] isEqualToString:@"TGTA"] || [args[1] isEqualToString:@"TARGETA"])	return A4PARAMS_FX_LFO2.DESTINATION_A;
		if([args[1] isEqualToString:@"TGTB"] || [args[1] isEqualToString:@"TARGETB"])	return A4PARAMS_FX_LFO2.DESTINATION_B;
		if([args[1] isEqualToString:@"DEPA"] || [args[1] isEqualToString:@"DEPTHA"])	return A4PARAMS_FX_LFO2.DEPTH_A;
		if([args[1] isEqualToString:@"DEPB"] || [args[1] isEqualToString:@"DEPTHB"])	return A4PARAMS_FX_LFO2.DEPTH_B;
	}
	
	return A4NULL;
}

@end
