//
//  MDTrackParams.h
//  sysexingApp
//
//  Created by Jakob Penca on 5/20/12.
//
//

#import <Foundation/Foundation.h>




@interface MDKitTrackParams : NSObject
- (void)setParam:(uint8_t) i toValue:(uint8_t) val;
- (uint8_t) valueForParam:(uint8_t)i;
@end
