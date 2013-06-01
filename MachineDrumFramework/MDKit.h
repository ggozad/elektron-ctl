//
//  MDKit.h
//  sysexingApp
//
//  Created by Jakob Penca on 5/20/12.
//
//

#import <Foundation/Foundation.h>
#import "MDKitTrack.h"

@interface MDKit : NSObject
@property uint8_t originalPosition;
@property (strong, nonatomic) NSData  *kitName;
@property (strong, nonatomic) NSArray *tracks;
@property (strong, nonatomic) NSMutableArray *reverbSettings;
@property (strong, nonatomic) NSMutableArray *delaySettings;
@property (strong, nonatomic) NSMutableArray *eqSettings;
@property (strong, nonatomic) NSMutableArray *dynamicsSettings;

+ (MDKit *) kitWithKit:(MDKit *)k;
+ (MDKit *) kit;
+ (MDKit *) kitWithData:(NSData *)data;
+ (MDKit *) kitWithRandomParametersAndDrumModels;

- (NSData *) sysexData;
- (void) setName:(NSString *)s;
- (NSString *)name;
- (void)setReverbParam:(uint8_t)param toValue:(uint8_t)val;
- (uint8_t)valueForReverbParam:(uint8_t)param;
- (void)setDelayParam:(uint8_t)param toValue:(uint8_t)val;
- (uint8_t)valueForDelayParam:(uint8_t)param;
- (void)setEQParam:(uint8_t)param toValue:(uint8_t)val;
- (uint8_t)valueForEQParam:(uint8_t)param;
- (void)setDynamixParam:(uint8_t)param toValue:(uint8_t)val;
- (uint8_t)valueForDynamicsParam:(uint8_t)param;

@end
