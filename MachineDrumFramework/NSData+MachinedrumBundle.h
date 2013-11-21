//
//  NSData+MachinedrumBundle.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MachinedrumBundle)
+ (NSData *) dataFromMachinedrumBundleResourceWithName:(NSString *)name ofType:(NSString *)type;
@end
