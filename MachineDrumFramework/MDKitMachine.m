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
	
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,		// ROM
	21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,										// ROM
	32, 33, 34, 35,																	// RAM
	
};

@implementation MDKitMachine

+ (NSString *)machineNameStringFromMachineID:(MDMachineID)mid
{
	NSString *synthMethod = @"???";
	NSString *machine = @"???";
	
	if(mid >= 0 && mid <= 3)
	{
		synthMethod = @"GND";
		if(mid == 0) machine = @"--";
		if(mid == 1) machine = @"SN";
		if(mid == 2) machine = @"NS";
		if(mid == 3) machine = @"IM";
	}
	if(mid >= 16 && mid <= 28)
	{
		synthMethod = @"TRX";
		if(mid == 16) machine = @"BD";
		if(mid == 17) machine = @"SD";
		if(mid == 18) machine = @"XT";
		if(mid == 19) machine = @"CP";
		if(mid == 20) machine = @"RS";
		if(mid == 21) machine = @"CB";
		if(mid == 22) machine = @"CH";
		if(mid == 23) machine = @"OH";
		if(mid == 24) machine = @"CY";
		if(mid == 25) machine = @"MA";
		if(mid == 26) machine = @"CL";
		if(mid == 27) machine = @"XC";
		if(mid == 28) machine = @"B2";
		
	}
	if(mid >= 32 && mid <= 39)
	{
		synthMethod = @"EFM";
		if(mid == 32) machine = @"BD";
		if(mid == 33) machine = @"SD";
		if(mid == 34) machine = @"XT";
		if(mid == 35) machine = @"CP";
		if(mid == 36) machine = @"RS";
		if(mid == 37) machine = @"CB";
		if(mid == 38) machine = @"HH";
		if(mid == 39) machine = @"CY";
	}
	if(mid >= 48 && mid <= 63) synthMethod = @"E12";
	if(mid >= 64 && mid <= 72) synthMethod = @"P-I";
	if(mid >= 80 && mid <= 85) synthMethod = @"INP";
	if(mid >= 96 && mid <= 111) synthMethod = @"MID";
	if(mid >= 112 && mid <= 123) synthMethod = @"CTR";
	
	
	return [NSString stringWithFormat:@"%@ %@", synthMethod, machine];
}

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
