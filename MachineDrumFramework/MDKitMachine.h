//
//  MDMachine.h
//  sysexingApp
//
//  Created by Jakob Penca on 5/20/12.
//
//

#import <Foundation/Foundation.h>

typedef uint8_t MDMachineID;
typedef NSUInteger MDMachineName;

#define MDMachineNumberOfMachinesTotal 78

typedef const enum MDMachineNames
{
	MDMachineName_GND_EM,
	MDMachineName_GND_SN,
	MDMachineName_GND_NS,
	MDMachineName_GND_IM, // 4
	         
	MDMachineName_TRX_BD,
	MDMachineName_TRX_SD,
	MDMachineName_TRX_XT,
	MDMachineName_TRX_CP,
	MDMachineName_TRX_RS,
	MDMachineName_TRX_CB,
	MDMachineName_TRX_CH,
	MDMachineName_TRX_OH,
	MDMachineName_TRX_CY,
	MDMachineName_TRX_MA,
	MDMachineName_TRX_CL,
	MDMachineName_TRX_XC,
	MDMachineName_TRX_B2,  //17
	         
	MDMachineName_EFM_BD,
	MDMachineName_EFM_SD,
	MDMachineName_EFM_XT,
	MDMachineName_EFM_CP,
	MDMachineName_EFM_RS,
	MDMachineName_EFM_CB,
	MDMachineName_EFM_HH,
	MDMachineName_EFM_CY, //25
	         
	MDMachineName_E12_BD,
	MDMachineName_E12_SD,
	MDMachineName_E12_HT,
	MDMachineName_E12_LT,
	MDMachineName_E12_CP,
	MDMachineName_E12_RS,
	MDMachineName_E12_CB,
	MDMachineName_E12_CH,
	MDMachineName_E12_OH,
	MDMachineName_E12_RC,
	MDMachineName_E12_CC,
	MDMachineName_E12_BR,
	MDMachineName_E12_TA,
	MDMachineName_E12_TR,
	MDMachineName_E12_SH,
	MDMachineName_E12_BC, //41
	         
	MDMachineName_P_I_BD,
	MDMachineName_P_I_SD,
	MDMachineName_P_I_MT,
	MDMachineName_P_I_ML,
	MDMachineName_P_I_MA,
	MDMachineName_P_I_RS,
	MDMachineName_P_I_RC,
	MDMachineName_P_I_CC,
	MDMachineName_P_I_HH, // 50
	         
	MDMachineName_INP_GA,
	MDMachineName_INP_GB,
	MDMachineName_INP_FA,
	MDMachineName_INP_FB,
	MDMachineName_INP_EA,
	MDMachineName_INP_EB, // 56
	         
	MDMachineName_MID_00,
	MDMachineName_MID_01,
	MDMachineName_MID_02,
	MDMachineName_MID_03,
	MDMachineName_MID_04,
	MDMachineName_MID_05,
	MDMachineName_MID_06,
	MDMachineName_MID_07,
	MDMachineName_MID_08,
	MDMachineName_MID_09,
	MDMachineName_MID_10,
	MDMachineName_MID_11,
	MDMachineName_MID_12,
	MDMachineName_MID_13,
	MDMachineName_MID_14,
	MDMachineName_MID_15, // 72
	         
	MDMachineName_CTR_AL,
	MDMachineName_CTR_8P,
	MDMachineName_CTR_RE,
	MDMachineName_CTR_GB,
	MDMachineName_CTR_EQ,
	MDMachineName_CTR_DX  // 78
}
MDMachineNames;

@interface MDKitMachine : NSObject
+ (MDMachineID) machineIDForMachineName:(MDMachineName)name;
+ (MDMachineName)machineNameFromMachineID:(MDMachineID)mid;
@end
