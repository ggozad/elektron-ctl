//
//  NSData+MachinedrumBundle.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "NSData+MachinedrumBundle.h"
#import "NSBundle+MachinedrumBundle.h"

@implementation NSData (MachinedrumBundle)

+ (NSData *)dataFromMachinedrumBundleResourceWithName:(NSString *)name ofType:(NSString *)type
{
	NSString *filePath = [[[[NSBundle machinedrumResourcesBundle] resourcePath] stringByAppendingPathComponent:name] stringByAppendingPathExtension:type];
	
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	
	return data;
}

@end
