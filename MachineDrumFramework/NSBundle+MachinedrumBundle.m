//
//  NSBundle+MachinedrumBundle.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "NSBundle+MachinedrumBundle.h"

@implementation NSBundle (MachinedrumBundle)

+ (NSBundle*)machinedrumResourcesBundle
{
    static dispatch_once_t onceToken;
    static NSBundle *machinedrumResourcesBundle = nil;
    
	dispatch_once(&onceToken, ^{
		
		
		NSString *bundleName = @"MachinedrumBundle";
		
#if TARGET_OS_IPHONE
	
		bundleName = [bundleName stringByAppendingString:@"-iOS"];
#else
		bundleName = [bundleName stringByAppendingString:@"-Mac"];
#endif
        
		machinedrumResourcesBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:bundleName withExtension:@"bundle"]];
    });
	
    return machinedrumResourcesBundle;
}


@end
