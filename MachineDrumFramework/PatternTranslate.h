//
//  PatternTranslate.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/22/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDPattern;

@interface PatternTranslate : NSObject
@property (strong, nonatomic) MDPattern *mdPattern;
+ (PatternTranslate *) sharedInstance;
- (void) translateCurrentMDPatternForA4;
@end
