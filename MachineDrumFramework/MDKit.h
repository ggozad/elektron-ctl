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
@property (strong, nonatomic) NSArray *reverbSettings;
@property (strong, nonatomic) NSArray *delaySettings;
@property (strong, nonatomic) NSArray *eqSettings;
@property (strong, nonatomic) NSArray *dynamicsSettings;

+ (MDKit *) kitWithKit:(MDKit *)k;
+ (MDKit *) kit;
+ (MDKit *) kitWithData:(NSData *)data;
+ (MDKit *) kitWithRandomParametersAndDrumModels;
- (NSData *) sysexData;
- (void) setName:(NSString *)s;

@end
