//
//  MachineDrum.h
//  sysexingApp
//
//  Created by Jakob Penca on 5/19/12.
//
//

#import <Foundation/Foundation.h>
#import "MDPattern.h"



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

@end
