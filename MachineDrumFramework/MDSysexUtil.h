//
//  MDSysexUtil.h
//  sysexingApp
//
//  Created by Jakob Penca on 6/11/12.
//
//

#import <Foundation/Foundation.h>

@interface MDSysexUtil : NSObject

+ (NSData *) dataWithInvalidBytesStrippedFromData:(NSData *)data;
+ (NSData *) dataFromHexString:(NSString *)hexStr;
+ (NSData *) dataPackedWith7BitSysexEncoding:(NSData *)inData;
+ (NSData *) dataUnpackedFrom7BitSysexEncoding:(NSData *)inData;
+ (NSMutableArray *)numbersFromBytes:(const char *)bytes withLength:(NSUInteger)length;
+ (NSData *) dataFromNumbersArray:(NSArray *)numbersArray;

+ (BOOL) compareData:(NSData *)data0 withData:(NSData *)data1;
+ (NSString *)md5StringFromData:(NSData *)data;

+ (NSString *)getBitStringForInt:(int)value;

@end
