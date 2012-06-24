//
//  MDMachine.m
//  sysexingApp
//
//  Created by Jakob Penca on 5/20/12.
//
//

#import "MDKitMachine.h"
#import "MDPitch.h"


const uint8_t MDMachineIDs[] =
{
	0, 1, 2, 3,																		// GND
	16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28,								// TRX
	32, 33, 34, 35, 36, 37, 38, 39,													// EFM
	48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63,					// E12
	64, 65, 66, 67, 68, 69, 70, 71, 72,												// P-I
	80, 81, 82, 83, 84, 85,															// INP
	96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107,	108, 109, 110, 111,		// MID
	112, 113, 120, 121, 122, 123,													// CTR
};


const MDMachineAbsoluteNoteRange machineNoteRanges[] =
{
	{},
};


@implementation MDKitMachine

+ (MDMachineID)machineIDForMachineName:(MDMachineName)name
{
	if(name >= MDMachineNumberOfMachinesTotal)
		return 0;
	
	return MDMachineIDs[name];
}

+ (MDMachineName)machineNameFromMachineID:(MDMachineID)mid
{
	if(mid > 255) return 0;
	
	for (NSUInteger i = 0; i < MDMachineNumberOfMachinesTotal; i++)
		if(mid == MDMachineIDs[i]) return i;
	
	return 0;
}

@end
