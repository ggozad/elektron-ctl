//
//  A4Sound.h
//  A4Sysex
//
//  Created by Jakob Penca on 3/31/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4SysexMessage.h"


extern const UInt16 A4SoundParamIndices[];
extern const uint8_t A4SoundParamMaxValues[];
extern const uint8_t A4SoundParamMinValues[];

typedef enum A4SoundParam
{
	A4SoundParam_OSC1_NEG 				,	// negative flag for OSC 1 & 2 finetune. bit 3 = OSC2, bit 5 = OSC1
	A4SoundParam_OSC1_TUN 				,	// 0x40 = 0, 0x00 = -63, 0x7f = +63
	A4SoundParam_OSC1_FIN 				,	// 0x00 = 0, 0x7e = +63
	A4SoundParam_OSC1_DET 				,	// 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_OSC1_TRK 				,	// 0x01 = ON, 0x00 = OFF
	A4SoundParam_OSC1_LEV 				,	// 0x00 - 0x7f
	A4SoundParam_OSC1_WAV 				,	// 0x00 - 0x07
	A4SoundParam_OSC1_SUB 				,	// 0x00 - 0x04
	A4SoundParam_OSC1_PW  				,	// 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_OSC1_SPD 				,	// 0x00 - 0x7f
	A4SoundParam_OSC1_PWM 				,   // 0x00 - 0x7f
	A4SoundParam_NOIS_SNH 				,	// 0x00 - 0x7f
	A4SoundParam_NOIS_FAD 				,	// 0x00 - 0x7f
	A4SoundParam_NOIS_LEV 				,	// 0x00 - 0x7f
	A4SoundParam_OSC2_TUN 				,	// 0x40 = 0, 0x00 = -63, 0x7f = +63
	A4SoundParam_OSC2_FIN 				,	// 0x00 = 0, 0x7e = +63
	A4SoundParam_OSC2_DET 				,	// 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_OSC2_TRK 				,	// 0x01 = ON, 0x00 = OFF
	A4SoundParam_OSC2_LEV 				,	// 0x00 - 0x7f
	A4SoundParam_OSC2_WAV 				,	// 0x00 - 0x07
	A4SoundParam_OSC2_SUB 				,	// 0x00 - 0x04
	A4SoundParam_OSC2_PW  				,	// 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_OSC2_SPD 				,	// 0x00 - 0x7f
	A4SoundParam_OSC2_PWM 				,   // 0x00 - 0x7f
	A4SoundParam_OSC_AM1  				,   // 0x00 - 0x01
	A4SoundParam_OSC_AM2  				,   // 0x00 - 0x01
	A4SoundParam_OSC_SMD  				,   // 0x00 - 0x03
	A4SoundParam_OSC_SNC  				,   // 0x00 - 0x7f
	A4SoundParam_OSC_BND  				,   // 0x00 - 0x7f 0x40 = 0
	A4SoundParam_OSC_SLI  				,   // 0x00 - 0x7f
	A4SoundParam_OSC_TRG  				,   // 0x00 - 0x01
	A4SoundParam_OSC_FAD  				,   // 0x00 - 0x7f 0x40 = 0
	A4SoundParam_OSC_SPD  				,   // 0x00 - 0x7f
	A4SoundParam_OSC_VIB  				,   // 0x00 - 0x7f
	A4SoundParam_FILT_FRQ1_UNKNOWN_FLAG ,  // 0x00 - 0x01 ?????
	A4SoundParam_FILT_FRQ1_COARSE		,  // 0x00 - 0x7f
	A4SoundParam_FILT_FRQ1_FINE			,  // 0x00 - 0x7f
	A4SoundParam_FILT_RES1				,  // 0x00 - 0x7f
	A4SoundParam_FILT_OVR1				,  // 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_FILT_TRK1				,  // 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_FILT_DEP1				,  // 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_FILT_FRQ2_UNKNOWN_FLAG ,  // 0x00 - 0x10 ?????
	A4SoundParam_FILT_FRQ2_COARSE		,  // 0x00 - 0x7f
	A4SoundParam_FILT_FRQ2_FINE			,  // 0x00 - 0x7f
	A4SoundParam_FILT_RES2				,  // 0x00 - 0x7f
	A4SoundParam_FILT_TYP2				,  // 0x00 - 0x06
	A4SoundParam_FILT_TRK2				,  // 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_FILT_DEP2				,  // 0x00 - 0x7f, 0x40 = 0	
	A4SoundParam_AMP_ATK				,  // 0x00 - 0x7f
	A4SoundParam_AMP_DEC				,  // 0x00 - 0x7f
	A4SoundParam_AMP_SUS				,  // 0x00 - 0x7f
	A4SoundParam_AMP_REL				,  // 0x00 - 0x7f
	A4SoundParam_AMP_SHP				,  // 0x00 - 0x0b
	A4SoundParam_AMP_CHO				,  // 0x00 - 0x7f
	A4SoundParam_AMP_DEL				,  // 0x00 - 0x7f
	A4SoundParam_AMP_REV				,  // 0x00 - 0x7f
	A4SoundParam_AMP_PAN				,  // 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_AMP_VOL				,  // 0x00 - 0x7f	
	A4SoundParam_ENVF_ATK				,  // 0x00 - 0x7f
	A4SoundParam_ENVF_DEC				,  // 0x00 - 0x7f
	A4SoundParam_ENVF_SUS				,  // 0x00 - 0x7f
	A4SoundParam_ENVF_REL				,  // 0x00 - 0x7f
	A4SoundParam_ENVF_SHP				,  // 0x00 - 0x7f
	A4SoundParam_ENVF_LEN				,  // 0x00 - 0x7f
	A4SoundParam_ENVF_DST1				,  //	???
	A4SoundParam_ENVF_DST2				,  //	???
	A4SoundParam_ENVF_DEP1				,  //	 0xaf & 0xb0 ?????
	A4SoundParam_ENVF_DEP2				,  //	 0xb1 & 0xb2 & 0xb3 ?????
	A4SoundParam_ENV2_ATK				,  // 0x00 - 0x7f
	A4SoundParam_ENV2_DEC				,  // 0x00 - 0x7f
	A4SoundParam_ENV2_SUS				,  // 0x00 - 0x7f
	A4SoundParam_ENV2_REL				,  // 0x00 - 0x7f
	A4SoundParam_ENV2_SHP				,  // 0x00 - 0x7f
	A4SoundParam_ENV2_LEN				,  // 0x00 - 0x7f
	A4SoundParam_ENV2_DST1				,  //	???
	A4SoundParam_ENV2_DST2				,  //	???
	A4SoundParam_ENV2_DEP1				,  //	 0xb2 & 0xb4 & 0xb5 ?????
	A4SoundParam_ENV2_DEP2				,  //	 0xb2 & 0xb6 & 0xb7 ?????
	A4SoundParam_LFO1_SPD				,  //	 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_LFO1_MUL				,  //	 0x00 - 0x0b
	A4SoundParam_LFO1_FAD				,  //	 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_LFO1_SPH				,  //	 0x00 - 0x7f,
	A4SoundParam_LFO1_MOD				,  //	 0x00 - 0x04
	A4SoundParam_LFO1_WAV				,  //	 0x00 - 0x06
	A4SoundParam_LFO1_DST1				,  //	 ???
	A4SoundParam_LFO1_DST2				,  //	 ???
	A4SoundParam_LFO1_DEP1				,  //	 0xda & 0xdd & 0xde ????
	A4SoundParam_LFO1_DEP2				,  //	 0xda & 0xdf & 0xe0 ????	
	A4SoundParam_LFO2_SPD				,  //	 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_LFO2_MUL				,  //	 0x00 - 0x0b
	A4SoundParam_LFO2_FAD				,  //	 0x00 - 0x7f, 0x40 = 0
	A4SoundParam_LFO2_SPH				,  //	 0x00 - 0x7f,
	A4SoundParam_LFO2_MOD				,  //	 0x00 - 0x04
	A4SoundParam_LFO2_WAV				,  //	 0x00 - 0x06
	A4SoundParam_LFO2_DST1				,  //	 ???
	A4SoundParam_LFO2_DST2				,  //	 ???
	A4SoundParam_LFO2_DEP1				,  //	 0xe1 & 0xe3 ????
	A4SoundParam_LFO2_DEP2				,  //	 0xe4 & 0xe5 ????
	A4SoundParam_ItemCount
}
A4SoundParam;

@interface A4Sound : A4SysexMessage
@property (strong, nonatomic) NSString *name;
- (void) setParam:(A4SoundParam)param toFloatValue:(float)val;
- (float) floatValueForParam:(A4SoundParam)param;
@end
