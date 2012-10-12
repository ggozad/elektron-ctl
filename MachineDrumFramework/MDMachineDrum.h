//
//  MachineDrum.h
//  sysexingApp
//
//  Created by Jakob Penca on 5/19/12.
//
//

#import <Foundation/Foundation.h>
#import "MDPattern.h"
#import "MDMachinedrumGlobalSettings.h"

typedef enum MDOutput
{
	MDOutput_A,
	MDOutput_B,
	MDOutput_C,
	MDOutput_D,
	MDOutput_E,
	MDOutput_F,
	MDOutput_Main,
}
MDOutput;

@class MDMachineDrum;

@protocol MDMachineDrumDelegate <NSObject>
- (void) machineDrum:(MDMachineDrum *)md wantsToSendSysExData:(NSData *)data;
@end

@interface MDMachineDrum : NSObject
@property (weak, nonatomic) id<MDMachineDrumDelegate> delegate;
@property int tempo;
@property (strong, nonatomic) NSString *currentKitName;

- (void) saveCurrentKitToSlot:(NSUInteger) num;
- (void) loadPattern:(NSUInteger) num;
- (void) loadKit:(NSUInteger) num;

- (void) requestKitDumpForSlot:(uint8_t) num;
- (void) requestGlobalSettingsDumpForSlot:(uint8_t) num;
- (void) requestPatternDumpForSlot:(uint8_t)num;

- (void) requestCurrentKitNumber;
- (void) requestCurrentPatternNumber;
- (void) requestCurrentGlobalSettingsSlot;

- (void) sendPattern:(MDPattern *)pattern;
- (void) sendGlobalSettings:(MDMachinedrumGlobalSettings *)settings;
- (void) setSampleName:(NSString *)name atSlot:(NSUInteger)slot;
- (void) routeTrack:(uint8_t)channel toOutput:(MDOutput)output;

@end
