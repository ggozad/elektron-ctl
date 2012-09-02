//
//  MDMachinedrumGlobalSettingsParser.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/2/12.
//  Copyright (c) 2012 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MDMachinedrumGlobalSettings;

@interface MDMachinedrumGlobalSettingsParser : NSObject
+ (id) globalSettingsFromSysexData:(NSData *)d;
+ (id) sysexDataFromGlobalSettings:(MDMachinedrumGlobalSettings *)globalSettings;
@end
