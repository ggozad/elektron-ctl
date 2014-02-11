//
//  A4Params.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/24/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <stdint.h>
#import <MacTypes.h>

#pragma once

typedef uint8_t A4Param;
typedef float A4TrackerParam_t;
#define A4NULL ((uint8_t) 0xFF)

#define A4ParamOsc1Pit 0x12 // mod only
#define A4ParamOsc1Tun 0x00 // 16bit lock only
#define A4ParamOsc1Det 0x02
#define A4ParamOsc1Trk 0x04
#define A4ParamOsc1Lev 0x06
#define A4ParamOsc1Wav 0x08
#define A4ParamOsc1Sub 0x0A
#define A4ParamOsc1PW  0x0C
#define A4ParamOsc1SPD 0x0E
#define A4ParamOsc1PWM 0x10

#define A4ParamNoisSH  0x15
#define A4ParamNoisFad 0x16
#define A4ParamNoisLev 0x17

#define A4ParamOsc2Pit 0x13 // mod only
#define A4ParamOsc2Tun 0x01 // 16bit
#define A4ParamOsc2Det 0x03
#define A4ParamOsc2Trk 0x05
#define A4ParamOsc2Lev 0x07
#define A4ParamOsc2Wav 0x09
#define A4ParamOsc2Sub 0x0B
#define A4ParamOsc2PW  0x0D
#define A4ParamOsc2SPD 0x0F
#define A4ParamOsc2PWM 0x11
#define A4ParamOsc12Pi 0x14 // mod only

#define A4ParamOscAm1 0x18
#define A4ParamOscSmd 0x1A
#define A4ParamOscSnc 0x1B
#define A4ParamOscBnd 0x1C
#define A4ParamOscSli 0x1D
#define A4ParamOscAm2 0x19
#define A4ParamOscTrg 0x1E // lock only
#define A4ParamOscFad 0x1F
#define A4ParamOscSpd 0x20
#define A4ParamOscVib 0x21

#define A4ParamFiltFr1 0x22 // 16bit
#define A4ParamFiltRs1 0x23
#define A4ParamFiltOd1 0x24
#define A4ParamFiltTr1 0x25 // lock only
#define A4ParamFiltDp1 0x26
#define A4ParamFiltFr2 0x27 // 16bit
#define A4ParamFiltRs2 0x28
#define A4ParamFiltTp2 0x29 // lock only
#define A4ParamFiltTr2 0x2A // lock only
#define A4ParamFiltDp2 0x2B
#define A4ParamFiltF12 0x2C // mod only

#define A4ParamAmpAtk  0x35
#define A4ParamAmpDec  0x38
#define A4ParamAmpSus  0x3B
#define A4ParamAmpRel  0x3E
#define A4ParamAmpShp  0x41
#define A4ParamAmpCho  0x2D
#define A4ParamAmpDel  0x2E
#define A4ParamAmpRev  0x2F
#define A4ParamAmpPan  0x30
#define A4ParamAmpVol  0x31

#define A4ParamAmpAcc  0x32 

#define A4ParamEnv1Atk  0x33
#define A4ParamEnv1Dec  0x36
#define A4ParamEnv1Sus  0x39
#define A4ParamEnv1Rel  0x3C
#define A4ParamEnv1Shp  0x3F
#define A4ParamEnv1Len  0x42
#define A4ParamEnv1DsA  0x44 // lock only
#define A4ParamEnv1DpA  0x48 // 16bit
#define A4ParamEnv1DsB  0x45 // lock only
#define A4ParamEnv1DpB  0x49 // 16bit

#define A4ParamEnv2Atk  0x34
#define A4ParamEnv2Dec  0x37
#define A4ParamEnv2Sus  0x3A
#define A4ParamEnv2Rel  0x3D
#define A4ParamEnv2Shp  0x40
#define A4ParamEnv2Len  0x43
#define A4ParamEnv2DsA  0x46 // lock only
#define A4ParamEnv2DpA  0x4A // 16bit
#define A4ParamEnv2DsB  0x47 // lock only
#define A4ParamEnv2DpB  0x4B // 16bit

#define A4ParamLfo1Spd	0x4C
#define A4ParamLfo1Mul	0x4E
#define A4ParamLfo1Fad	0x50
#define A4ParamLfo1Sph	0x52
#define A4ParamLfo1Mod	0x54
#define A4ParamLfo1Wav	0x56
#define A4ParamLfo1DsA	0x58 // lock only
#define A4ParamLfo1DpA	0x5C // 16bit
#define A4ParamLfo1DsB	0x59 // lock only
#define A4ParamLfo1DpB	0x5D // 16bit

#define A4ParamLfo2Spd	0x4D
#define A4ParamLfo2Mul	0x4F
#define A4ParamLfo2Fad	0x51
#define A4ParamLfo2Sph	0x53
#define A4ParamLfo2Mod	0x55
#define A4ParamLfo2Wav	0x57
#define A4ParamLfo2DsA	0x5A // lock only
#define A4ParamLfo2DpA	0x5E // 16bit
#define A4ParamLfo2DsB	0x5B // lock only
#define A4ParamLfo2DpB	0x5F // 16bit

#define A4ParamFxExtChoL 0x04
#define A4ParamFxExtDelL 0x05
#define A4ParamFxExtRevL 0x06
#define A4ParamFxExtPanL 0x02
#define A4ParamFxExtVolL 0x00
#define A4ParamFxExtChoR 0x07
#define A4ParamFxExtDelR 0x08
#define A4ParamFxExtRevR 0x09
#define A4ParamFxExtPanR 0x03
#define A4ParamFxExtVolR 0x01

#define A4ParamFxChoPre 0x1A
#define A4ParamFxChoSpd 0x1B
#define A4ParamFxChoDep 0x1C
#define A4ParamFxChoWid 0x1D
#define A4ParamFxChoFdb 0x1E
#define A4ParamFxChoHpf 0x1F
#define A4ParamFxChoLpf 0x20
#define A4ParamFxChoDel 0x21
#define A4ParamFxChoRev 0x22
#define A4ParamFxChoVol 0x23

#define A4ParamFxDelTim 0x24
#define A4ParamFxDelX   0x25
#define A4ParamFxDelWid 0x27
#define A4ParamFxDelFdb 0x28
#define A4ParamFxDelHpf 0x29
#define A4ParamFxDelLpf 0x2A
#define A4ParamFxDelOvr 0x2B
#define A4ParamFxDelRev 0x2C
#define A4ParamFxDelVol 0x2D

#define A4ParamFxRevPre 0x2E
#define A4ParamFxRevDec 0x2F
#define A4ParamFxRevFrq 0x30
#define A4ParamFxRevGai 0x31
#define A4ParamFxRevHpf 0x32
#define A4ParamFxRevLpf 0x33
#define A4ParamFxRevVol 0x34

#define A4ParamFxLfo1Spd 0x35
#define A4ParamFxLfo1Mul 0x37
#define A4ParamFxLfo1Fad 0x39
#define A4ParamFxLfo1Sph 0x3B
#define A4ParamFxLfo1Mod 0x3D
#define A4ParamFxLfo1Wav 0x3F
#define A4ParamFxLfo1DsA 0x41
#define A4ParamFxLfo1DpA 0x45
#define A4ParamFxLfo1DsB 0x42
#define A4ParamFxLfo1DpB 0x46

#define A4ParamFxLfo2Spd 0x36
#define A4ParamFxLfo2Mul 0x38
#define A4ParamFxLfo2Fad 0x3A
#define A4ParamFxLfo2Sph 0x3C
#define A4ParamFxLfo2Mod 0x3E
#define A4ParamFxLfo2Wav 0x40
#define A4ParamFxLfo2DsA 0x43
#define A4ParamFxLfo2DpA 0x47
#define A4ParamFxLfo2DsB 0x44
#define A4ParamFxLfo2DpB 0x48

#define A4ParamLockableCount 92
#define A4ParamEnv1TargetCount 50
#define A4ParamEnv2TargetCount 62
#define A4ParamLfo1TargetCount 56
#define A4ParamLfo2TargetCount 68
#define A4ParamModTargetsCount 74

#define A4ParamLayoutCount 96
#define A4ParamFxLockableCount 56
#define A4ParamFxLfo1TargetCount 36
#define A4ParamFxLfo2TargetCount 42
#define A4ParamFxModTargetCount 48

typedef struct A4ParamPageOsc
{
	A4Param TUNING;
	A4Param DETUNING;
	A4Param KEYTRACK;
	A4Param LEVEL;
	A4Param WAVEFORM;
	A4Param SUBOSCILLATOR;
	A4Param PULSEWIDTH;
	A4Param PWM_SPEED;
	A4Param PWM_DEPTH;
}
A4ParamPageOsc;

const A4ParamPageOsc A4PARAMS_OSC1;
const A4ParamPageOsc A4PARAMS_OSC2;

typedef struct
{
	A4Param SAMPLEHOLD;
	A4Param FADE;
	A4Param LEVEL;
}
A4ParamPageNoise;

const A4ParamPageNoise A4PARAMS_NOIS;

typedef struct
{
	A4Param	AM1;
	A4Param AM2;
	A4Param SYNC_MODE;
	A4Param SYNC_AMOUNT;
	A4Param BENDDEPTH;
	A4Param SLIDETIME;
	A4Param RETRIG;
	A4Param VIBRATO_FADE;
	A4Param VIBRATO_SPEED;
	A4Param VIBRATO_DEPTH;
}
A4ParamPageOscCommon;

const A4ParamPageOscCommon A4PARAMS_OSC;

typedef struct A4ParamPageFilters
{
	A4Param F1_FREQUENCY;
	A4Param F1_RESONANCE;
	A4Param F1_OVERDRIVE;
	A4Param F1_KEYTRACK;
	A4Param F1_MODDEPTH;
	A4Param F2_FREQUENCY;
	A4Param F2_RESONANCE;
	A4Param F2_TYPE;
	A4Param F2_KEYTRACK;
	A4Param F2_MODDEPTH;
}
A4ParamPageFilters;

const A4ParamPageFilters A4PARAMS_FILT;

typedef struct A4ParamPageAmp
{
	A4Param	ENV_ATTACK;
	A4Param ENV_DECAY;
	A4Param ENV_SUSTAIN;
	A4Param ENV_RELEASE;
	A4Param SHAPE;
	A4Param SEND_CHORUS;
	A4Param SEND_DELAY;
	A4Param SEND_REVERB;
	A4Param PANNING;
	A4Param VOLUME;
	A4Param ACCENT;
}
A4ParamPageAmp;

const A4ParamPageAmp A4PARAMS_AMP;

typedef struct A4ParamPageEnv
{
	A4Param ENV_ATTACK;
	A4Param ENV_DECAY;
	A4Param ENV_SUSTAIN;
	A4Param ENV_RELEASE;
	A4Param SHAPE;
	A4Param GATELENGTH;
	A4Param DESTINATION_A;
	A4Param DEPTH_A;
	A4Param DESTINATION_B;
	A4Param DEPTH_B;
}
A4ParamPageEnv;

const A4ParamPageEnv A4PARAMS_ENV1;
const A4ParamPageEnv A4PARAMS_ENV2;

typedef struct
{
	A4Param SPEED;
	A4Param MULTIPLIER;
	A4Param FADE;
	A4Param STARTPHASE;
	A4Param MODE;
	A4Param WAVEFORM;
	A4Param DESTINATION_A;
	A4Param DEPTH_A;
	A4Param DESTINATION_B;
	A4Param DEPTH_B;
}
A4ParamPageLfo;

const A4ParamPageLfo A4PARAMS_LFO1;
const A4ParamPageLfo A4PARAMS_LFO2;

typedef struct
{
	A4Param L_CHORUS;
	A4Param L_DELAY;
	A4Param L_REVERB;
	A4Param L_PANNING;
	A4Param L_VOLUME;
	A4Param R_CHORUS;
	A4Param R_DELAY;
	A4Param R_REVERB;
	A4Param R_PANNING;
	A4Param R_VOLUME;
}
A4ParamPageFxExt;

const A4ParamPageFxExt A4PARAMS_FX_EXT;

typedef struct
{
	A4Param PREDELAY;
	A4Param SPEED;
	A4Param DEPTH;
	A4Param WIDTH;
	A4Param FEEDBACK;
	A4Param HIGHPASS;
	A4Param LOWPASS;
	A4Param SEND_DELAY;
	A4Param SEND_REVERB;
	A4Param VOLUME;
}
A4ParamPageFxCho;

const A4ParamPageFxCho A4PARAMS_FX_CHOR;

typedef struct
{
	A4Param TIME;
	A4Param PINGPONG;
	A4Param WIDTH;
	A4Param FEEDBACK;
	A4Param HIGHPASS;
	A4Param LOWPASS;
	A4Param OVERDRIVE;
	A4Param SEND_REVERB;
	A4Param VOLUME;
}
A4ParamPageFxDel;

const A4ParamPageFxDel A4PARAMS_FX_DELAY;

typedef struct
{
	A4Param PREDELAY;
	A4Param DECAY;
	A4Param SHELV_FREQUENCY;
	A4Param SHELV_GAIN;
	A4Param HIGHPASS;
	A4Param LOWPASS;
	A4Param VOLUME;
}
A4ParamPageFxRev;

const A4ParamPageFxRev A4PARAMS_FX_REVERB;
const A4ParamPageLfo A4PARAMS_FX_LFO1;
const A4ParamPageLfo A4PARAMS_FX_LFO2;

A4Param A4ParamLockableByIndex(uint8_t i);
A4Param A4ParamEnv1TargetByIndex(uint8_t i);
A4Param A4ParamEnv2TargetByIndex(uint8_t i);
A4Param A4ParamLfo1TargetByIndex(uint8_t i);
A4Param A4ParamLfo2TargetByIndex(uint8_t i);
A4Param A4ParamModlTargetByIndex(uint8_t i);
uint8_t A4ParamIndexOfParamInModTargets(A4Param param);
uint8_t A4ParamIndexOfParamLockableParams(A4Param param);

A4Param A4ParamFxLockableByIndex(uint8_t i);
A4Param A4ParamFxLfo1TargetByIndex(uint8_t i);
A4Param A4ParamFxLfo2TargetByIndex(uint8_t i);
A4Param A4ParamFxModlTargetByIndex(uint8_t i);
uint8_t A4ParamFxIndexOfParamInFxModTargets(A4Param param);

bool A4ParamIs16Bit(A4Param p);
bool A4ParamIsLockable(A4Param p);
bool A4ParamIsEnv1Target(A4Param p);
bool A4ParamIsEnv2Target(A4Param p);
bool A4ParamIsLfo1Target(A4Param p);
bool A4ParamIsLfo2Target(A4Param p);
bool A4ParamIsModTarget(A4Param p);
bool A4ParamIsModulatorDestination(A4Param p);
int8_t A4ParamIndexOfModTargetInModSource(A4Param tgt, A4Param src);
A4Param A4ParamModTargetByIndexInModSource(int8_t idx, A4Param src);
int8_t A4ParamModTargetCountInModSource(A4Param src);

bool A4ParamFxIs16Bit(A4Param p);
bool A4ParamFxIsLockable(A4Param p);
bool A4ParamFxIsLfo1Target(A4Param p);
bool A4ParamFxIsLfo2Target(A4Param p);
bool A4ParamFxIsModTarget(A4Param p);
bool A4ParamFxIsModulatorDestination(A4Param p);
bool A4ParamIsSlideable(A4Param p);

UInt16  A4KitOffsetForFxParam(A4Param p);
uint8_t A4SoundOffsetForParam(A4Param p);
double A4ParamMin(A4Param p);
double A4ParamMax(A4Param p);
uint8_t A4ParamMaxi(A4Param p);
double A4ParamFxMin(A4Param p);
double A4ParamFxMax(A4Param p);

float A4ParamEnvGateLengthMultiplier(uint8_t val);

