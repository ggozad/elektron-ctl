//
//  A4Params.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/22/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Params.h"

const A4ParamPageOsc A4PARAMS_OSC1 =
{
	A4ParamOsc1Tun,
	A4ParamOsc1Det,
	A4ParamOsc1Trk,
	A4ParamOsc1Lev,
	A4ParamOsc1Wav,
	A4ParamOsc1Sub,
	A4ParamOsc1PW,
	A4ParamOsc1SPD,
	A4ParamOsc1PWM
};

const A4ParamPageOsc A4PARAMS_OSC2 =
{
	A4ParamOsc2Tun,
	A4ParamOsc2Det,
	A4ParamOsc2Trk,
	A4ParamOsc2Lev,
	A4ParamOsc2Wav,
	A4ParamOsc2Sub,
	A4ParamOsc2PW,
	A4ParamOsc2SPD,
	A4ParamOsc2PWM
};

const A4ParamPageNoise A4PARAMS_NOIS =
{
	A4ParamNoisSH,
	A4ParamNoisFad,
	A4ParamNoisLev
};

const A4ParamPageOscCommon A4PARAMS_OSC =
{
	A4ParamOscAm1,
	A4ParamOscAm2,
	A4ParamOscSmd,
	A4ParamOscSnc,
	A4ParamOscBnd,
	A4ParamOscSli,
	A4ParamOscTrg,
	A4ParamOscFad,
	A4ParamOscSpd,
	A4ParamOscVib
};

const A4ParamPageFilters A4PARAMS_FILT =
{
	A4ParamFiltFr1,
	A4ParamFiltRs1,
	A4ParamFiltOd1,
	A4ParamFiltTr1,
	A4ParamFiltDp1,
	A4ParamFiltFr2,
	A4ParamFiltRs2,
	A4ParamFiltTp2,
	A4ParamFiltTr2,
	A4ParamFiltDp2
};

const A4ParamPageAmp A4PARAMS_AMP =
{
	A4ParamAmpAtk,
	A4ParamAmpDec,
	A4ParamAmpSus,
	A4ParamAmpRel,
	A4ParamAmpShp,
	A4ParamAmpCho,
	A4ParamAmpDel,
	A4ParamAmpRev,
	A4ParamAmpPan,
	A4ParamAmpVol,
	A4ParamAmpAcc
};

const A4ParamPageEnv A4PARAMS_ENV1 =
{
	A4ParamEnv1Atk,
	A4ParamEnv1Dec,
	A4ParamEnv1Sus,
	A4ParamEnv1Rel,
	A4ParamEnv1Shp,
	A4ParamEnv1Len,
	A4ParamEnv1DsA,
	A4ParamEnv1DpA,
	A4ParamEnv1DsB,
	A4ParamEnv1DpB
};

const A4ParamPageEnv A4PARAMS_ENV2 =
{
	A4ParamEnv2Atk,
	A4ParamEnv2Dec,
	A4ParamEnv2Sus,
	A4ParamEnv2Rel,
	A4ParamEnv2Shp,
	A4ParamEnv2Len,
	A4ParamEnv2DsA,
	A4ParamEnv2DpA,
	A4ParamEnv2DsB,
	A4ParamEnv2DpB
};

const A4ParamPageLfo A4PARAMS_LFO1 =
{
	A4ParamLfo1Spd,
	A4ParamLfo1Mul,
	A4ParamLfo1Fad,
	A4ParamLfo1Sph,
	A4ParamLfo1Mod,
	A4ParamLfo1Wav,
	A4ParamLfo1DsA,
	A4ParamLfo1DpA,
	A4ParamLfo1DsB,
	A4ParamLfo1DpB
};

const A4ParamPageLfo A4PARAMS_LFO2 =
{
	A4ParamLfo2Spd,
	A4ParamLfo2Mul,
	A4ParamLfo2Fad,
	A4ParamLfo2Sph,
	A4ParamLfo2Mod,
	A4ParamLfo2Wav,
	A4ParamLfo2DsA,
	A4ParamLfo2DpA,
	A4ParamLfo2DsB,
	A4ParamLfo2DpB
};


const A4ParamPageFxExt A4PARAMS_FX_EXT =
{
	A4ParamFxExtChoL,
	A4ParamFxExtDelL,
	A4ParamFxExtRevL,
	A4ParamFxExtPanL,
	A4ParamFxExtVolL,
	A4ParamFxExtChoR,
	A4ParamFxExtDelR,
	A4ParamFxExtRevR,
	A4ParamFxExtPanR,
	A4ParamFxExtVolR
};

const A4ParamPageFxCho A4PARAMS_FX_CHOR =
{
	A4ParamFxChoPre,
	A4ParamFxChoSpd,
	A4ParamFxChoDep,
	A4ParamFxChoWid,
	A4ParamFxChoFdb,
	A4ParamFxChoHpf,
	A4ParamFxChoLpf,
	A4ParamFxChoDel,
	A4ParamFxChoRev,
	A4ParamFxChoVol
};

const A4ParamPageFxDel A4PARAMS_FX_DELAY =
{
	A4ParamFxDelTim,
	A4ParamFxDelX,
	A4ParamFxDelWid,
	A4ParamFxDelFdb,
	A4ParamFxDelHpf,
	A4ParamFxDelLpf,
	A4ParamFxDelOvr,
	A4ParamFxDelRev,
	A4ParamFxDelVol,
};

const A4ParamPageFxRev A4PARAMS_FX_REVERB =
{
	A4ParamFxRevPre,
	A4ParamFxRevDec,
	A4ParamFxRevFrq,
	A4ParamFxRevGai,
	A4ParamFxRevHpf,
	A4ParamFxRevLpf,
	A4ParamFxRevVol,
};

const A4ParamPageLfo A4PARAMS_FX_LFO1 =
{
	A4ParamFxLfo1Spd,
	A4ParamFxLfo1Mul,
	A4ParamFxLfo1Fad,
	A4ParamFxLfo1Sph,
	A4ParamFxLfo1Mod,
	A4ParamFxLfo1Wav,
	A4ParamFxLfo1DsA,
	A4ParamFxLfo1DpA,
	A4ParamFxLfo1DsB,
	A4ParamFxLfo1DpB,
};


const A4ParamPageLfo A4PARAMS_FX_LFO2 =
{
	A4ParamFxLfo2Spd,
	A4ParamFxLfo2Mul,
	A4ParamFxLfo2Fad,
	A4ParamFxLfo2Sph,
	A4ParamFxLfo2Mod,
	A4ParamFxLfo2Wav,
	A4ParamFxLfo2DsA,
	A4ParamFxLfo2DpA,
	A4ParamFxLfo2DsB,
	A4ParamFxLfo2DpB,
};

static const A4Param paramLayout[] =
{
	A4ParamOsc1Tun,
	A4ParamOsc2Tun,
	A4ParamOsc1Det,
	A4ParamOsc2Det,
	A4ParamOsc1Trk,
	A4ParamOsc2Trk,
	A4ParamOsc1Lev,
	A4ParamOsc2Lev,
	A4ParamOsc1Wav,
	A4ParamOsc2Wav,
	A4ParamOsc1Sub,
	A4ParamOsc2Sub,
	A4ParamOsc1PW,
	A4ParamOsc2PW,
	A4ParamOsc1SPD,
	A4ParamOsc2SPD,
	A4ParamOsc1PWM,
	A4ParamOsc2PWM,
	
	A4NULL,
	A4NULL,
	A4NULL,
	A4ParamNoisSH,
	A4ParamNoisFad,
	A4ParamNoisLev,
	
	A4ParamOscAm1,
	A4ParamOscAm2,
	A4ParamOscSmd,
	A4ParamOscSnc,
	A4ParamOscBnd,
	A4ParamOscSli,
	A4ParamOscTrg,
	A4ParamOscFad,
	A4ParamOscSpd,
	A4ParamOscVib,
	
	A4ParamFiltFr1,
	A4ParamFiltRs1,
	A4ParamFiltOd1,
	A4ParamFiltTr1,
	A4ParamFiltDp1,
	A4ParamFiltFr2,
	A4ParamFiltRs2,
	A4ParamFiltTp2,
	A4ParamFiltTr2,
	A4ParamFiltDp2,
	
	A4NULL,			// filter2 range???
	A4ParamAmpCho,
	A4ParamAmpDel,
	A4ParamAmpRev,
	A4ParamAmpPan,
	A4ParamAmpVol,
	A4ParamAmpAcc,
	
	A4ParamEnv1Atk,
	A4ParamEnv2Atk,
	A4ParamAmpAtk,
	A4ParamEnv1Dec,
	A4ParamEnv2Dec,
	A4ParamAmpDec,
	A4ParamEnv1Sus,
	A4ParamEnv2Sus,
	A4ParamAmpSus,
	A4ParamEnv1Rel,
	A4ParamEnv2Rel,
	A4ParamAmpRel,
	A4ParamEnv1Shp,
	A4ParamEnv2Shp,
	A4ParamAmpShp,
	
	A4ParamEnv1Len,
	A4ParamEnv2Len,
	A4ParamEnv1DsA,
	A4ParamEnv1DsB,
	A4ParamEnv2DsA,
	A4ParamEnv2DsB,
	A4ParamEnv1DpA,
	A4ParamEnv1DpB,
	A4ParamEnv2DpA,
	A4ParamEnv2DpB,
	
	A4ParamLfo1Spd,
	A4ParamLfo2Spd,
	A4ParamLfo1Mul,
	A4ParamLfo2Mul,
	A4ParamLfo1Fad,
	A4ParamLfo2Fad,
	A4ParamLfo1Sph,
	A4ParamLfo2Sph,
	A4ParamLfo1Mod,
	A4ParamLfo2Mod,
	
	A4ParamLfo1Wav,
	A4ParamLfo2Wav,
	A4ParamLfo1DsA,
	A4ParamLfo1DsB,
	A4ParamLfo2DsA,
	A4ParamLfo2DsB,
	A4ParamLfo1DpA,
	A4ParamLfo1DpB,
	A4ParamLfo2DpA,
	A4ParamLfo2DpB,
};

static const uint8_t minVals[] =
{
	// osc 1
	0x0,	     // 0x40 = 0, 0x00 = -63, 0x7f = +63
	0x0,	     // 0x00 - 0x7f, 0x40 = 0
	0x0,     // 0x01 = ON, 0x00 = OFF
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x07
	0x0,     // 0x00 - 0x04
	0x0,     // 0x00 - 0x7f, 0x40 = 0
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	
	// noise
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	
	// osc 2
	0x0,     // 0x40 = 0, 0x00 = -63, 0x7f = +63
	0x0,     // 0x00 - 0x7f, 0x40 = 0
	0x0,     // 0x01 = ON, 0x00 = OFF
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x07
	0x0,     // 0x00 - 0x04
	0x0,     // 0x00 - 0x7f, 0x40 = 0
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	
	// osc common
	0x0,     // 0x00 - 0x01
	0x0,     // 0x00 - 0x01
	0x0,     // 0x00 - 0x03
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f 0x40 = 0
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x01
	0x0,     // 0x00 - 0x7f 0x40 = 0
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	
	// filters
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f, 0x40 = 0
	0x0,     // 0x00 - 0x7f, 0x40 = 0
	0x0,     // 0x00 - 0x7f, 0x40 = 0
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x06
	0x0,     // 0x00 - 0x7f, 0x40 = 0
	0x0,     // 0x00 - 0x7f, 0x40 = 0
	
	// amp
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x0b
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f, 0x40 = 0
	0x0,     // 0x00 - 0x7f
	
	// env 1
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,     // 0x00 - 0x7f
	0x0,    //	???
	0x0,    //	???
	0x0,   //	 0xaf & 0xb0 ?????
	0x0,   //	 0xb1 & 0xb2 & 0xb3 ?????
	
	// env 2
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	
	// lfo 1
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	
	// lfo 2
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,   //
	0x0,	//
	0x0,
	0x0,
	0x0,
	0x0,
	0x0,
};

static const uint8_t maxVals[] =
{
	0x7F,	// 0x40 = 0, 0x00 = -63, 0x7f = +63
	0x7F,	// 0x00 - 0x7f, 0x40 = 0
	0x01,	// 0x01 = ON, 0x00 = OFF
	0x7F,	// 0x00 - 0x7f
	0x07,	// 0x00 - 0x07
	0x04,	// 0x00 - 0x04
	0x7F,	// 0x00 - 0x7f, 0x40 = 0
	0x7F,	// 0x00 - 0x7f
	0x7F,   // 0x00 - 0x7f
	
	// noise
	0x7F,	// 0x00 - 0x7f
	0x7F,	// 0x00 - 0x7f
	0x7F,	// 0x00 - 0x7f
	
	// osc 2
	0x7F,	// 0x40 = 0, 0x00 = -63, 0x7f = +63
	0x7F,	// 0x00 - 0x7f, 0x40 = 0
	0x01,	// 0x01 = ON, 0x00 = OFF
	0x7F,	// 0x00 - 0x7f
	0x07,	// 0x00 - 0x07
	0x04,	// 0x00 - 0x04
	0x7F,	// 0x00 - 0x7f, 0x40 = 0
	0x7F,	// 0x00 - 0x7f
	0x7f,   // 0x00 - 0x7f
	
	// osc common
	0x01,   // 0x00 - 0x01
	0x01,   // 0x00 - 0x01
	0x03,   // 0x00 - 0x03
	0x7F,   // 0x00 - 0x7f
	0x7F,   // 0x00 - 0x7f 0x40 = 0
	0x7F,   // 0x00 - 0x7f
	0x01,   // 0x00 - 0x01
	0x7F,   // 0x00 - 0x7f 0x40 = 0
	0x7F,   // 0x00 - 0x7f
	0x7F,   // 0x00 - 0x7f
	
	// filters
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f, 0x40 = 0
	0x7F,  // 0x00 - 0x7f, 0x40 = 0
	0x7F,  // 0x00 - 0x7f, 0x40 = 0
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f
	0x06,  // 0x00 - 0x06
	0x7F,  // 0x00 - 0x7f, 0x40 = 0
	0x7F,  // 0x00 - 0x7f, 0x40 = 0
	
	// amp
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f
	0x0B,  // 0x00 - 0x0b
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f, 0x40 = 0
	0x7F,  // 0x00 - 0x7f
	0x7F,
	// env 1
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f
	0x0B,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f
	0x7F,  //	 0xaf & 0xb0 ?????
	0x7F,  //	 0xb1 & 0xb2 & 0xb3 ?????
	0x7F,  // 0x00 - 0x7f
	0x7F,  // 0x00 - 0x7f
	
	// env 2
	0x7F,
	0x7F,
	0x7F,
	0x7F,
	0x0B,
	0x7F,
	0x7F,
	0x7F,
	0x7f,
	0x7F,
	
	// lfo 1
	0x7F,  //	 0x00 - 0x7f, 0x40 = 0
	0x0B,  //	 0x00 - 0x0b,
	0x7F,  //	 0x00 - 0x7f
	0x7F,  //	 0x00 - 0x7f
	0x04,  //	 ???
	0x06,  //	 ???
	0x7F,  //	 0xda & 0xdd & 0xde ????
	0x7F,  //	 0xda & 0xdf & 0xe0 ????
	0x7F,  //	 0x00 - 0x7f, 0x40 = 0
	0x7F,  //	 0x00 - 0x0b
	
	// lfo 2
	0x7F,  //	 0x00 - 0x7f, 0x40 = 0
	0x0B,  //	 0x00 - 0x0b,
	0x7F,  //	 0x00 - 0x7f
	0x7F,  //	 0x00 - 0x7f
	0x04,  //	 ???
	0x06,  //	 ???
	0x7F,  //	 0xda & 0xdd & 0xde ????
	0x7F,  //	 0xda & 0xdf & 0xe0 ????
	0x7F,  //	 0x00 - 0x7f, 0x40 = 0
	0x7F,  //	 0x00 - 0x0b
};


static const UInt16 kitFxParamOffsets[] =
{
	0x05E4, // cho l
	0x05E6, // del l
	0x05E8, // rev l
	0x05E0, // pan l
	0x05DC, // vol l
	0x05EA, // cho r
	0x05EC, // del r
	0x05EE, // rev r
	0x05E2, // pan r
	0x05DE, // vol r
	
	0x0610, // cho pre
	0x0612, // cho spd
	0x0614, // cho dep
	0x0616, // cho wid
	0x0618, // cho fdb
	0x061A, // cho hpf
	0x061C, // cho lpf
	0x061E, // cho del
	0x0620, // cho rev
	0x0622, // cho vol
	
	0x0624, // del tim
	0x0626, // del X
	0x062A, // del wid
	0x062C, // del fdb
	0x062E, // del hpf
	0x0630, // del lpf
	0x0632, // del ovr
	0x0634, // del rev
	0x0636, // del vol
	
	0x0638, // rev pre
	0x063A, // rev dec
	0x063C, // rev frq
	0x063E, // rev gai
	0x0640, // rev hpf
	0x0642, // rev lpf
	0x0644, // rev vol
	
	0x0646, // lfo1 spd
	0x064A, // lfo1 mul
	0x064E, // lfo1 fad
	0x0652, // lfo1 sph
	0x0656, // lfo1 mod
	0x065A, // lfo1 wav
	0x065E, // lfo1 dsa
	0x0666, // lfo1 dpa
	0x0660, // lfo1 dsb
	0x0668, // lfo1 dpb
	
	0x0648, // lfo2 spd
	0x064C, // lfo2 mul
	0x0650, // lfo2 fad
	0x0654, // lfo2 sph
	0x0658, // lfo2 mod
	0x065C, // lfo2 wav
	0x0662, // lfo2 dsa
	0x066A, // lfo2 dpa
	0x0664, // lfo2 dsb
	0x066C, // lfo2 dpb
};


static const A4Param lockable[] =
{
	A4ParamOsc1Tun,  
	A4ParamOsc1Det, 
	A4ParamOsc1Trk, 
	A4ParamOsc1Lev, 
	A4ParamOsc1Wav,
	A4ParamOsc1Sub, 
	A4ParamOsc1PW, 
	A4ParamOsc1SPD, 
	A4ParamOsc1PWM,
	
	A4ParamNoisSH, 
	A4ParamNoisFad, 
	A4ParamNoisLev,
	
	A4ParamOsc2Tun,  
	A4ParamOsc2Det, 
	A4ParamOsc2Trk, 
	A4ParamOsc2Lev, 
	A4ParamOsc2Wav, 
	A4ParamOsc2Sub, 
	A4ParamOsc2PW, 
	A4ParamOsc2SPD, 
	A4ParamOsc2PWM,
	
	A4ParamOscAm1,  
	A4ParamOscAm2,
	A4ParamOscSmd,  
	A4ParamOscSnc,
	A4ParamOscBnd,
	A4ParamOscSli,
	A4ParamOscTrg,
	A4ParamOscFad,  
	A4ParamOscSpd,  
	A4ParamOscVib,
	
	A4ParamFiltFr1, 
	A4ParamFiltRs1, 
	A4ParamFiltOd1, 
	A4ParamFiltTr1,  
	A4ParamFiltDp1, 
	A4ParamFiltFr2, 
	A4ParamFiltRs2, 
	A4ParamFiltTp2,  
	A4ParamFiltTr2,  
	A4ParamFiltDp2,
	
	A4ParamAmpAtk,  
	A4ParamAmpDec,  
	A4ParamAmpSus,  
	A4ParamAmpRel,  
	A4ParamAmpShp,  
	A4ParamAmpCho,  
	A4ParamAmpDel,  
	A4ParamAmpRev,  
	A4ParamAmpPan,  
	A4ParamAmpVol,
	A4ParamAmpAcc,
	
	A4ParamEnv1Atk, 
	A4ParamEnv1Dec, 
	A4ParamEnv1Sus, 
	A4ParamEnv1Rel, 
	A4ParamEnv1Shp, 
	A4ParamEnv1Len, 
	A4ParamEnv1DsA, 
	A4ParamEnv1DpA, 
	A4ParamEnv1DsB, 
	A4ParamEnv1DpB,
	
	A4ParamEnv2Atk, 
	A4ParamEnv2Dec, 
	A4ParamEnv2Sus, 
	A4ParamEnv2Rel, 
	A4ParamEnv2Shp, 
	A4ParamEnv2Len, 
	A4ParamEnv2DsA, 
	A4ParamEnv2DpA, 
	A4ParamEnv2DsB, 
	A4ParamEnv2DpB,
	
	A4ParamLfo1Spd, 
	A4ParamLfo1Mul, 
	A4ParamLfo1Fad, 
	A4ParamLfo1Sph, 
	A4ParamLfo1Mod, 
	A4ParamLfo1Wav, 
	A4ParamLfo1DsA, 
	A4ParamLfo1DpA, 
	A4ParamLfo1DsB, 
	A4ParamLfo1DpB,
	
	A4ParamLfo2Spd, 
	A4ParamLfo2Mul, 
	A4ParamLfo2Fad, 
	A4ParamLfo2Sph, 
	A4ParamLfo2Mod, 
	A4ParamLfo2Wav, 
	A4ParamLfo2DsA, 
	A4ParamLfo2DpA, 
	A4ParamLfo2DsB, 
	A4ParamLfo2DpB, 
};



static const A4Param env1Targets[] =
{
	A4ParamOsc1Pit,
	A4ParamOsc1Det,
	A4ParamOsc1Trk,
	A4ParamOsc1Lev,
	A4ParamOsc1Wav,
	A4ParamOsc1Sub,
	A4ParamOsc1PW,
	A4ParamOsc1SPD,
	A4ParamOsc1PWM,
	
	A4ParamNoisSH,
	A4ParamNoisFad,
	A4ParamNoisLev,
	
	A4ParamOsc2Pit,
	A4ParamOsc2Det,
	A4ParamOsc2Trk,
	A4ParamOsc2Lev,
	A4ParamOsc2Wav,
	A4ParamOsc2Sub,
	A4ParamOsc2PW,
	A4ParamOsc2SPD,
	A4ParamOsc2PWM,
	
	A4ParamOsc12Pi,
	
	A4ParamOscAm1,
	A4ParamOscSmd,
	A4ParamOscSnc,
	A4ParamOscBnd,
	A4ParamOscSli,
	A4ParamOscAm2,
	A4ParamOscFad,
	A4ParamOscSpd,
	A4ParamOscVib,
	
	A4ParamFiltFr1,
	A4ParamFiltRs1,
	A4ParamFiltOd1,
	A4ParamFiltDp1,
	A4ParamFiltFr2,
	A4ParamFiltRs2,
	A4ParamFiltDp2,
	
	A4ParamFiltF12,
	
	A4ParamAmpAtk,
	A4ParamAmpDec,
	A4ParamAmpSus,
	A4ParamAmpRel,
	A4ParamAmpShp,
	A4ParamAmpCho,
	A4ParamAmpDel,
	A4ParamAmpRev,
	A4ParamAmpPan,
	A4ParamAmpVol,
	
	A4ParamAmpAcc,
};

static const A4Param env2Targets[] =
{
	A4ParamOsc1Pit,
	A4ParamOsc1Det,
	A4ParamOsc1Trk,
	A4ParamOsc1Lev,
	A4ParamOsc1Wav,
	A4ParamOsc1Sub,
	A4ParamOsc1PW,
	A4ParamOsc1SPD,
	A4ParamOsc1PWM,
	
	A4ParamNoisSH,
	A4ParamNoisFad,
	A4ParamNoisLev,
	
	A4ParamOsc2Pit,
	A4ParamOsc2Det,
	A4ParamOsc2Trk,
	A4ParamOsc2Lev,
	A4ParamOsc2Wav,
	A4ParamOsc2Sub,
	A4ParamOsc2PW,
	A4ParamOsc2SPD,
	A4ParamOsc2PWM,
	
	A4ParamOsc12Pi,
	
	A4ParamOscAm1,
	A4ParamOscSmd,
	A4ParamOscSnc,
	A4ParamOscBnd,
	A4ParamOscSli,
	A4ParamOscAm2,
	A4ParamOscFad,
	A4ParamOscSpd,
	A4ParamOscVib,
	
	A4ParamFiltFr1,
	A4ParamFiltRs1,
	A4ParamFiltOd1,
	A4ParamFiltDp1,
	A4ParamFiltFr2,
	A4ParamFiltRs2,
	A4ParamFiltDp2,
	
	A4ParamFiltF12,
	
	A4ParamAmpAtk,
	A4ParamAmpDec,
	A4ParamAmpSus,
	A4ParamAmpRel,
	A4ParamAmpShp,
	A4ParamAmpCho,
	A4ParamAmpDel,
	A4ParamAmpRev,
	A4ParamAmpPan,
	A4ParamAmpVol,
	
	A4ParamAmpAcc,
	
	A4ParamEnv1Atk,
	A4ParamEnv1Dec,
	A4ParamEnv1Sus,
	A4ParamEnv1Rel,
	A4ParamEnv1DpA,
	A4ParamEnv1DpB,
	
	A4ParamLfo1Spd,
	A4ParamLfo1Mul,
	A4ParamLfo1Fad,
	A4ParamLfo1Sph,
	A4ParamLfo1DpA,
	A4ParamLfo1DpB,
};

static const A4Param lfo1Targets[] =
{
	A4ParamOsc1Pit,
	A4ParamOsc1Det,
	A4ParamOsc1Trk,
	A4ParamOsc1Lev,
	A4ParamOsc1Wav,
	A4ParamOsc1Sub,
	A4ParamOsc1PW,
	A4ParamOsc1SPD,
	A4ParamOsc1PWM,
	
	A4ParamNoisSH,
	A4ParamNoisFad,
	A4ParamNoisLev,
	
	A4ParamOsc2Pit,
	A4ParamOsc2Det,
	A4ParamOsc2Trk,
	A4ParamOsc2Lev,
	A4ParamOsc2Wav,
	A4ParamOsc2Sub,
	A4ParamOsc2PW,
	A4ParamOsc2SPD,
	A4ParamOsc2PWM,
	
	A4ParamOsc12Pi,
	
	A4ParamOscAm1,
	A4ParamOscSmd,
	A4ParamOscSnc,
	A4ParamOscBnd,
	A4ParamOscSli,
	A4ParamOscAm2,
	A4ParamOscFad,
	A4ParamOscSpd,
	A4ParamOscVib,
	
	A4ParamFiltFr1,
	A4ParamFiltRs1,
	A4ParamFiltOd1,
	A4ParamFiltDp1,
	A4ParamFiltFr2,
	A4ParamFiltRs2,
	A4ParamFiltDp2,
	
	A4ParamFiltF12,
	
	A4ParamAmpAtk,
	A4ParamAmpDec,
	A4ParamAmpSus,
	A4ParamAmpRel,
	A4ParamAmpShp,
	A4ParamAmpCho,
	A4ParamAmpDel,
	A4ParamAmpRev,
	A4ParamAmpPan,
	A4ParamAmpVol,
	
	A4ParamAmpAcc,
	
	A4ParamEnv1Atk,
	A4ParamEnv1Dec,
	A4ParamEnv1Sus,
	A4ParamEnv1Rel,
	A4ParamEnv1DpA,
	A4ParamEnv1DpB,
};

static const A4Param lfo2Targets[] =
{
	A4ParamOsc1Pit,
	A4ParamOsc1Det,
	A4ParamOsc1Trk,
	A4ParamOsc1Lev,
	A4ParamOsc1Wav,
	A4ParamOsc1Sub,
	A4ParamOsc1PW,
	A4ParamOsc1SPD,
	A4ParamOsc1PWM,
	
	A4ParamNoisSH,
	A4ParamNoisFad,
	A4ParamNoisLev,
	
	A4ParamOsc2Pit,
	A4ParamOsc2Det,
	A4ParamOsc2Trk,
	A4ParamOsc2Lev,
	A4ParamOsc2Wav,
	A4ParamOsc2Sub,
	A4ParamOsc2PW,
	A4ParamOsc2SPD,
	A4ParamOsc2PWM,
	
	A4ParamOsc12Pi,
	
	A4ParamOscAm1,
	A4ParamOscSmd,
	A4ParamOscSnc,
	A4ParamOscBnd,
	A4ParamOscSli,
	A4ParamOscAm2,
	A4ParamOscFad,
	A4ParamOscSpd,
	A4ParamOscVib,
	
	A4ParamFiltFr1,
	A4ParamFiltRs1,
	A4ParamFiltOd1,
	A4ParamFiltDp1,
	A4ParamFiltFr2,
	A4ParamFiltRs2,
	A4ParamFiltDp2,
	
	A4ParamFiltF12,
	
	A4ParamAmpAtk,
	A4ParamAmpDec,
	A4ParamAmpSus,
	A4ParamAmpRel,
	A4ParamAmpShp,
	A4ParamAmpCho,
	A4ParamAmpDel,
	A4ParamAmpRev,
	A4ParamAmpPan,
	A4ParamAmpVol,
	
	A4ParamAmpAcc,
	
	A4ParamEnv1Atk,
	A4ParamEnv1Dec,
	A4ParamEnv1Sus,
	A4ParamEnv1Rel,
	A4ParamEnv1DpA,
	A4ParamEnv1DpB,

	A4ParamEnv2Atk,
	A4ParamEnv2Dec,
	A4ParamEnv2Sus,
	A4ParamEnv2Rel,
	A4ParamEnv2DpA,
	A4ParamEnv2DpB,
	
	A4ParamLfo1Spd,
	A4ParamLfo1Mul,
	A4ParamLfo1Fad,
	A4ParamLfo1Sph,
	A4ParamLfo1DpA,
	A4ParamLfo1DpB,
};

static const A4Param modTargets[] =
{
	A4ParamOsc1Pit,
	A4ParamOsc1Det,
	A4ParamOsc1Trk,
	A4ParamOsc1Lev,
	A4ParamOsc1Wav,
	A4ParamOsc1Sub,
	A4ParamOsc1PW,
	A4ParamOsc1SPD,
	A4ParamOsc1PWM,
	
	A4ParamNoisSH,
	A4ParamNoisFad,
	A4ParamNoisLev,
	
	A4ParamOsc2Pit,
	A4ParamOsc2Det,
	A4ParamOsc2Trk,
	A4ParamOsc2Lev,
	A4ParamOsc2Wav,
	A4ParamOsc2Sub,
	A4ParamOsc2PW,
	A4ParamOsc2SPD,
	A4ParamOsc2PWM,
	
	A4ParamOsc12Pi,
	
	A4ParamOscAm1,
	A4ParamOscSmd,
	A4ParamOscSnc,
	A4ParamOscBnd,
	A4ParamOscSli,
	A4ParamOscAm2,
	A4ParamOscFad,
	A4ParamOscSpd,
	A4ParamOscVib,
	
	A4ParamFiltFr1,
	A4ParamFiltRs1,
	A4ParamFiltOd1,
	A4ParamFiltDp1,
	A4ParamFiltFr2,
	A4ParamFiltRs2,
	A4ParamFiltDp2,
	
	A4ParamFiltF12,
	
	A4ParamAmpAtk,
	A4ParamAmpDec,
	A4ParamAmpSus,
	A4ParamAmpRel,
	A4ParamAmpShp,
	A4ParamAmpCho,
	A4ParamAmpDel,
	A4ParamAmpRev,
	A4ParamAmpPan,
	A4ParamAmpVol,
	
	A4ParamAmpAcc,
	
	A4ParamEnv1Atk,
	A4ParamEnv1Dec,
	A4ParamEnv1Sus,
	A4ParamEnv1Rel,
	A4ParamEnv1DpA,
	A4ParamEnv1DpB,
	
	A4ParamEnv2Atk,
	A4ParamEnv2Dec,
	A4ParamEnv2Sus,
	A4ParamEnv2Rel,
	A4ParamEnv2DpA,
	A4ParamEnv2DpB,
	
	A4ParamLfo1Spd,
	A4ParamLfo1Mul,
	A4ParamLfo1Fad,
	A4ParamLfo1Sph,
	A4ParamLfo1DpA,
	A4ParamLfo1DpB,
	
	A4ParamLfo2Spd,
	A4ParamLfo2Mul,
	A4ParamLfo2Fad,
	A4ParamLfo2Sph,
	A4ParamLfo2DpA,
	A4ParamLfo2DpB,
	
	INT16_MIN
};



const A4Param fxLockable[] =
{
	A4ParamFxExtChoL,
	A4ParamFxExtDelL,
	A4ParamFxExtRevL,
	A4ParamFxExtPanL,
	A4ParamFxExtVolL,
	A4ParamFxExtChoR,
	A4ParamFxExtDelR,
	A4ParamFxExtRevR,
	A4ParamFxExtPanR,
	A4ParamFxExtVolR,
	
	A4ParamFxChoPre,
	A4ParamFxChoSpd,
	A4ParamFxChoDep,
	A4ParamFxChoWid,
	A4ParamFxChoFdb,
	A4ParamFxChoHpf,
	A4ParamFxChoLpf,
	A4ParamFxChoDel,
	A4ParamFxChoRev,
	A4ParamFxChoVol,
	
	A4ParamFxDelTim,
	A4ParamFxDelX,
	A4ParamFxDelWid,
	A4ParamFxDelFdb,
	A4ParamFxDelHpf,
	A4ParamFxDelLpf,
	A4ParamFxDelOvr,
	A4ParamFxDelRev,
	A4ParamFxDelVol,
	
	A4ParamFxRevPre,
	A4ParamFxRevDec,
	A4ParamFxRevFrq,
	A4ParamFxRevGai,
	A4ParamFxRevHpf,
	A4ParamFxRevLpf,
	A4ParamFxRevVol,
	
	A4ParamFxLfo1Spd,
	A4ParamFxLfo1Mul,
	A4ParamFxLfo1Fad,
	A4ParamFxLfo1Sph,
	A4ParamFxLfo1Mod,
	A4ParamFxLfo1Wav,
	A4ParamFxLfo1DsA,
	A4ParamFxLfo1DpA,
	A4ParamFxLfo1DsB,
	A4ParamFxLfo1DpB,
	
	A4ParamFxLfo2Spd,
	A4ParamFxLfo2Mul,
	A4ParamFxLfo2Fad,
	A4ParamFxLfo2Sph,
	A4ParamFxLfo2Mod,
	A4ParamFxLfo2Wav,
	A4ParamFxLfo2DsA,
	A4ParamFxLfo2DpA,
	A4ParamFxLfo2DsB,
	A4ParamFxLfo2DpB,
};

const A4Param fxLfo1Targets[] =
{
	A4ParamFxExtChoL,
	A4ParamFxExtDelL,
	A4ParamFxExtRevL,
	A4ParamFxExtPanL,
	A4ParamFxExtVolL,
	A4ParamFxExtChoR,
	A4ParamFxExtDelR,
	A4ParamFxExtRevR,
	A4ParamFxExtPanR,
	A4ParamFxExtVolR,
	
	A4ParamFxChoPre,
	A4ParamFxChoSpd,
	A4ParamFxChoDep,
	A4ParamFxChoWid,
	A4ParamFxChoFdb,
	A4ParamFxChoHpf,
	A4ParamFxChoLpf,
	A4ParamFxChoDel,
	A4ParamFxChoRev,
	A4ParamFxChoVol,
	
	A4ParamFxDelTim,
	A4ParamFxDelX,
	A4ParamFxDelWid,
	A4ParamFxDelFdb,
	A4ParamFxDelHpf,
	A4ParamFxDelLpf,
	A4ParamFxDelOvr,
	A4ParamFxDelRev,
	A4ParamFxDelVol,
	
	A4ParamFxRevPre,
	A4ParamFxRevDec,
	A4ParamFxRevFrq,
	A4ParamFxRevGai,
	A4ParamFxRevHpf,
	A4ParamFxRevLpf,
	A4ParamFxRevVol,
};

const A4Param fxLfo2Targets[] =
{
	A4ParamFxExtChoL,
	A4ParamFxExtDelL,
	A4ParamFxExtRevL,
	A4ParamFxExtPanL,
	A4ParamFxExtVolL,
	A4ParamFxExtChoR,
	A4ParamFxExtDelR,
	A4ParamFxExtRevR,
	A4ParamFxExtPanR,
	A4ParamFxExtVolR,
	
	A4ParamFxChoPre,
	A4ParamFxChoSpd,
	A4ParamFxChoDep,
	A4ParamFxChoWid,
	A4ParamFxChoFdb,
	A4ParamFxChoHpf,
	A4ParamFxChoLpf,
	A4ParamFxChoDel,
	A4ParamFxChoRev,
	A4ParamFxChoVol,
	
	A4ParamFxDelTim,
	A4ParamFxDelX,
	A4ParamFxDelWid,
	A4ParamFxDelFdb,
	A4ParamFxDelHpf,
	A4ParamFxDelLpf,
	A4ParamFxDelOvr,
	A4ParamFxDelRev,
	A4ParamFxDelVol,
	
	A4ParamFxRevPre,
	A4ParamFxRevDec,
	A4ParamFxRevFrq,
	A4ParamFxRevGai,
	A4ParamFxRevHpf,
	A4ParamFxRevLpf,
	A4ParamFxRevVol,
	
	A4ParamFxLfo1Spd,
	A4ParamFxLfo1Mul,
	A4ParamFxLfo1Fad,
	A4ParamFxLfo1Sph,
	A4ParamFxLfo1DpA,
	A4ParamFxLfo1DpB,
};

const A4Param fxModTargets[] =
{
	A4ParamFxExtChoL,
	A4ParamFxExtDelL,
	A4ParamFxExtRevL,
	A4ParamFxExtPanL,
	A4ParamFxExtVolL,
	A4ParamFxExtChoR,
	A4ParamFxExtDelR,
	A4ParamFxExtRevR,
	A4ParamFxExtPanR,
	A4ParamFxExtVolR,
	
	A4ParamFxChoPre,
	A4ParamFxChoSpd,
	A4ParamFxChoDep,
	A4ParamFxChoWid,
	A4ParamFxChoFdb,
	A4ParamFxChoHpf,
	A4ParamFxChoLpf,
	A4ParamFxChoDel,
	A4ParamFxChoRev,
	A4ParamFxChoVol,
	
	A4ParamFxDelTim,
	A4ParamFxDelX,
	A4ParamFxDelWid,
	A4ParamFxDelFdb,
	A4ParamFxDelHpf,
	A4ParamFxDelLpf,
	A4ParamFxDelOvr,
	A4ParamFxDelRev,
	A4ParamFxDelVol,
	
	A4ParamFxRevPre,
	A4ParamFxRevDec,
	A4ParamFxRevFrq,
	A4ParamFxRevGai,
	A4ParamFxRevHpf,
	A4ParamFxRevLpf,
	A4ParamFxRevVol,
	
	A4ParamFxLfo1Spd,
	A4ParamFxLfo1Mul,
	A4ParamFxLfo1Fad,
	A4ParamFxLfo1Sph,
	A4ParamFxLfo1DpA,
	A4ParamFxLfo1DpB,
	
	A4ParamFxLfo2Spd,
	A4ParamFxLfo2Mul,
	A4ParamFxLfo2Fad,
	A4ParamFxLfo2Sph,
	A4ParamFxLfo2DpA,
	A4ParamFxLfo2DpB,
};

A4Param A4ParamLockableByIndex(uint8_t i)
{
	if(i >= A4ParamLockableCount) return A4NULL;
	return lockable[i];
}

A4Param A4ParamEnv1TargetByIndex(uint8_t i)
{
	if(i >= A4ParamEnv1TargetCount) return A4NULL;
	return env1Targets[i];
}

A4Param A4ParamEnv2TargetByIndex(uint8_t i)
{
	if(i >= A4ParamEnv2TargetCount) return A4NULL;
	return env2Targets[i];
}

A4Param A4ParamLfo1TargetByIndex(uint8_t i)
{
	if(i >= A4ParamLfo1TargetCount) return A4NULL;
	return lfo1Targets[i];
}
A4Param A4ParamLfo2TargetByIndex(uint8_t i)
{
	if(i >= A4ParamLfo2TargetCount) return A4NULL;
	return lfo2Targets[i];
}

A4Param A4ParamModlTargetByIndex(uint8_t i)
{
	if(i >= A4ParamModTargetsCount) return A4NULL;
	return modTargets[i];
}

A4Param A4ParamModTargetByIndexInModSource(int8_t idx, A4Param src)
{
	if(idx >= A4ParamModTargetCountInModSource(src)) return A4NULL;
	
	switch(src)
	{
		case A4ParamLfo1DsA:
		case A4ParamLfo1DsB:
		{
			return lfo1Targets[idx];
			break;
		}
		case A4ParamLfo2DsA:
		case A4ParamLfo2DsB:
		{
			return lfo2Targets[idx];
			break;
		}
		case A4ParamEnv1DsA:
		case A4ParamEnv1DsB:
		{
			return env1Targets[idx];
			break;
		}
		case A4ParamEnv2DsA:
		case A4ParamEnv2DsB:
		{
			return env2Targets[idx];
			break;
		}
		default:
		{
			return A4NULL;
			break;
		}
	}
}

A4Param A4ParamFxLockableByIndex(uint8_t i)
{
	if(i >= A4ParamFxLockableCount) return A4NULL;
	return fxLockable[i];
}

A4Param A4ParamFxLfo1TargetByIndex(uint8_t i)
{
	if(i >= A4ParamFxLfo1TargetCount) return A4NULL;
	return fxLfo1Targets[i];
}

A4Param A4ParamFxLfo2TargetByIndex(uint8_t i)
{
	if(i >= A4ParamFxLfo2TargetCount) return A4NULL;
	return fxLfo2Targets[i];
}

bool A4ParamIs16Bit(uint8_t p)
{
	return (p == A4ParamOsc1Tun ||
			p == A4ParamOsc2Tun ||
			p == A4ParamFiltFr1 ||
			p == A4ParamFiltFr2 ||
			p == A4ParamEnv1DpA ||
			p == A4ParamEnv1DpB ||
			p == A4ParamEnv2DpA ||
			p == A4ParamEnv2DpB ||
			p == A4ParamLfo1DpA ||
			p == A4ParamLfo1DpB ||
			p == A4ParamLfo2DpA ||
			p == A4ParamLfo2DpB);
}

bool A4ParamIsModulatorDestination(A4Param p)
{
	return (p == A4ParamEnv1DsA ||
			p == A4ParamEnv1DsB ||
			p == A4ParamEnv2DsA ||
			p == A4ParamEnv2DsB ||
			p == A4ParamLfo1DsA ||
			p == A4ParamLfo1DsB ||
			p == A4ParamLfo2DsA ||
			p == A4ParamLfo2DsB);
}

uint8_t A4ParamIndexOf(A4Param p, const uint8_t *array, uint8_t arrayLength)
{
	for (uint8_t i = 0; i < arrayLength; i++)
	{
		if(p == array[i]) return i;
	}
	return 0xFF;
}

uint8_t A4ParamIndexOfParamInModTargets(A4Param param)
{
	return A4ParamIndexOf(param, modTargets, A4ParamModTargetsCount);
}

uint8_t A4ParamIndexOfParamLockableParams(A4Param param)
{
	return A4ParamIndexOf(param, lockable, A4ParamLockableCount);
}

bool A4ParamIsLockable(A4Param p)
{
	return A4ParamIndexOf(p, lockable, A4ParamLockableCount) != (uint8_t)A4NULL;
}

bool A4ParamIsEnv1Target(A4Param p)
{
	return A4ParamIndexOf(p, env1Targets, A4ParamEnv1TargetCount) != (uint8_t)A4NULL;
}

bool A4ParamIsEnv2Target(A4Param p)
{
	return A4ParamIndexOf(p, env2Targets, A4ParamEnv2TargetCount) != (uint8_t)A4NULL;
}

bool A4ParamIsLfo1Target(A4Param p)
{
	return A4ParamIndexOf(p, lfo1Targets, A4ParamLfo1TargetCount) != (uint8_t)A4NULL;
}

bool A4ParamIsLfo2Target(A4Param p)
{
	return A4ParamIndexOf(p, lfo2Targets, A4ParamLfo2TargetCount) != (uint8_t)A4NULL;
}

bool A4ParamIsModTarget(A4Param p)
{
	return A4ParamIndexOf(p, modTargets, A4ParamModTargetsCount) != (uint8_t)A4NULL;
}

int8_t A4ParamModTargetCountInModSource(A4Param src)
{
	int8_t len = A4NULL;
	switch(src)
	{
		case A4ParamLfo1DsA:
		case A4ParamLfo1DsB:
		{
			len = A4ParamLfo1TargetCount;
			break;
		}
		case A4ParamLfo2DsA:
		case A4ParamLfo2DsB:
		{
			len = A4ParamLfo2TargetCount;
			break;
		}
		case A4ParamEnv1DsA:
		case A4ParamEnv1DsB:
		{
			len = A4ParamEnv1TargetCount;
			break;
		}
		case A4ParamEnv2DsA:
		case A4ParamEnv2DsB:
		{
			len = A4ParamEnv2TargetCount;
			break;
		}
		default:
		{
			break;
		}
	}
	return len;
}

int8_t A4ParamIndexOfModTargetInModSource(A4Param tgt, A4Param src)
{
	const A4Param *srcList = NULL;
	uint8_t len = 0;
	switch(src)
	{
		case A4ParamLfo1DsA:
		case A4ParamLfo1DsB:
		{
			srcList = lfo1Targets;
			len = A4ParamLfo1TargetCount;
			break;
		}
		case A4ParamLfo2DsA:
		case A4ParamLfo2DsB:
		{
			srcList = lfo2Targets;
			len = A4ParamLfo2TargetCount;
			break;
		}
		case A4ParamEnv1DsA:
		case A4ParamEnv1DsB:
		{
			srcList = env1Targets;
			len = A4ParamEnv1TargetCount;
			break;
		}
		case A4ParamEnv2DsA:
		case A4ParamEnv2DsB:
		{
			srcList = env2Targets;
			len = A4ParamEnv2TargetCount;
			break;
		}
		default:
		{
			break;
		}
	}
	
	if(srcList != NULL)
	{
		return A4ParamIndexOf(tgt, srcList, len);
	}
	
	return A4NULL;
}


bool A4ParamFxIs16Bit(A4Param p)
{
	return (p == A4ParamFxLfo1DpA ||
			p == A4ParamFxLfo1DpB ||
			p == A4ParamFxLfo2DpA ||
			p == A4ParamFxLfo2DpB);
}

bool A4ParamFxIsModulatorDestination(A4Param param)
{
	return (param == A4PARAMS_FX_LFO1.DESTINATION_A ||
			param == A4PARAMS_FX_LFO1.DESTINATION_B ||
			param == A4PARAMS_FX_LFO2.DESTINATION_A ||
			param == A4PARAMS_FX_LFO2.DESTINATION_B);
}

bool A4ParamFxIsLockable(A4Param p)
{
	return A4ParamIndexOf(p, fxLockable, A4ParamFxLockableCount) != (uint8_t)A4NULL;
}

bool A4ParamFxIsLfo1Target(A4Param p)
{
	return A4ParamIndexOf(p, fxLfo1Targets, A4ParamFxLfo1TargetCount) != (uint8_t)A4NULL;
}

bool A4ParamFxIsLfo2Target(A4Param p)
{
	return A4ParamIndexOf(p, fxLfo2Targets, A4ParamFxLfo2TargetCount) != (uint8_t)A4NULL;
}

bool A4ParamFxIsModTarget(A4Param p)
{
	return A4ParamIndexOf(p, fxModTargets, A4ParamFxModTargetCount) != (uint8_t)A4NULL;
}

bool A4ParamIsSlideable(A4Param p)
{
	return
	    p == A4ParamOsc1Tun ||
	    p == A4ParamOsc1Det ||
	    p == A4ParamOsc1Lev ||
	    p == A4ParamOsc1PW  ||
	    p == A4ParamOsc1PWM ||
		p == A4ParamNoisLev ||
		p == A4ParamOsc2Tun ||
		p == A4ParamOsc2Det ||
		p == A4ParamOsc2Lev ||
		p == A4ParamOsc2PW  ||
		p == A4ParamOscVib  ||
		p == A4ParamFiltFr1 ||
		p == A4ParamFiltRs1 ||
		p == A4ParamFiltOd1 ||
		p == A4ParamFiltDp1 ||
		p == A4ParamFiltFr2 ||
		p == A4ParamFiltRs2 ||
		p == A4ParamFiltDp2 ||
		p == A4ParamAmpCho  ||
		p == A4ParamAmpDel  ||
		p == A4ParamAmpRev  ||
		p == A4ParamAmpPan  ||
		p == A4ParamAmpVol  ||
		p == A4ParamEnv1DpA ||
		p == A4ParamEnv1DpB ||
		p == A4ParamEnv2DpA ||
		p == A4ParamEnv2DpB ||
		p == A4ParamLfo1Spd ||
		p == A4ParamLfo1Mul ||
		p == A4ParamLfo1DpA ||
		p == A4ParamLfo1DpB ||
		p == A4ParamLfo2Spd ||
		p == A4ParamLfo2Mul ||
		p == A4ParamLfo2DpA ||
		p == A4ParamLfo2DpB
	;
}

A4Param A4ParamFxModlTargetByIndex(uint8_t i)
{
	if(i >= A4ParamFxModTargetCount) return A4NULL;
	return fxModTargets[i];
}


uint8_t A4ParamFxIndexOfParamInFxModTargets(A4Param param)
{
	return A4ParamIndexOf(param, fxModTargets, A4ParamFxModTargetCount);
}

uint8_t A4SoundOffsetForParam(A4Param p)
{
	uint8_t i = A4ParamIndexOf(p, paramLayout, A4ParamLayoutCount);
	if(i == (uint8_t)A4NULL) return A4NULL;
	return i;
}


UInt16 A4KitOffsetForFxParam(A4Param p)
{
	if(!A4ParamFxIsLockable(p)) return A4NULL;
	uint8_t i = A4ParamIndexOf(p, fxLockable, A4ParamFxLockableCount);
	if(p == (uint8_t)A4NULL) return A4NULL;
	return kitFxParamOffsets[i];
}


double A4ParamMin(A4Param p)
{
	if(p == A4ParamOsc12Pi ||
	   p == A4ParamFiltF12)
	{
		return 0x00;
	}
	uint8_t i = A4ParamIndexOf(p, lockable, A4ParamLockableCount);
	if(i == 0xFF) return 0xFF;
	return minVals[i];
}

double A4ParamMax(A4Param p)
{
	if(A4ParamIs16Bit(p)) return 128;
	if(p == A4ParamOsc12Pi ||
	   p == A4ParamFiltF12)
	{
		return 128;
	}
	uint8_t i = A4ParamIndexOf(p, lockable, A4ParamLockableCount);
	if(i == 0xFF) return 0xFF;
	return maxVals[i] + 1;
}

uint8_t A4ParamMaxi(A4Param p)
{
	if(A4ParamIs16Bit(p)) return 128;
	if(p == A4ParamOsc12Pi ||
	   p == A4ParamFiltF12)
	{
		return 128;
	}
	uint8_t i = A4ParamIndexOf(p, lockable, A4ParamLockableCount);
	if(i == 0xFF) return 0xFF;
	return maxVals[i];
}



double A4ParamFxMin(A4Param p)
{
	return 0;
}

double A4ParamFxMax(A4Param p)
{
	switch (p)
	{
		case A4ParamFxDelX:
		{
			return 1;
			break;
		}
		case A4ParamFxLfo1Mul:
		{
			return 11;
			break;
		}
		case A4ParamFxLfo1Mod:
		{
			return 4;
			break;
		}
		case A4ParamFxLfo1Wav:
		{
			return 6;
			break;
		}
		case A4ParamFxLfo2Mul:
		{
			return 11;
			break;
		}
		case A4ParamFxLfo2Mod:
		{
			return 4;
			break;
		}
		case A4ParamFxLfo2Wav:
		{
			return 6;
			break;
		}
		default: return 127;
	}
}






