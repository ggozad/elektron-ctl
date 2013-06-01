//
//  MDKit.m
//  sysexingApp
//
//  Created by Jakob Penca on 5/20/12.
//
//

#import "MDKit.h"
#import "MDSysexUtil.h"
#import "MDKitParser.h"


@interface MDKit()

- (NSMutableArray *)defaultReverbSettings;
- (NSMutableArray *)defaultDelaySettings;
- (NSMutableArray *)defaultEQSettings;
- (NSMutableArray *)defaultDynamicsSettings;
- (void) initTracks;



@end

@implementation MDKit
@synthesize tracks, kitName, originalPosition;

- (void)setName:(NSString *)s
{
	const char *inString = [s cStringUsingEncoding:NSASCIIStringEncoding];
	
	NSUInteger len = StrLength(inString);
	if(len > 8) len = 8;
	
	char nameBytes[16];
	for (int i = 0; i < 16; i++) nameBytes[i] = 0;
	for(int i = 0; i < len; i++)
		nameBytes[i] = inString[i];
	
	self.kitName = [NSData dataWithBytes:&nameBytes length:16];
}

- (NSString *)name
{
	const char *bytes = self.kitName.bytes;
	NSString *name = [NSString stringWithCString:bytes encoding:NSASCIIStringEncoding];
	return name;
}

- (NSData *)sysexData
{
	return [MDKitParser sysexDataFromKit:self];
}

+ (MDKit *)kitWithKit:(MDKit *)k
{
	return [self kitWithData:[k sysexData]];
}

+ (MDKit *)kit
{
	return [MDKit new];
}


+ (MDKit *)kitWithRandomParametersAndDrumModels
{
	MDKit *kit = [MDKit new];
	
	for (MDKitTrack *track in kit.tracks)
	{
		track.machine = [MDKitMachine machineIDForMachineName:arc4random_uniform(MDMachineNumberOfMachinesTotal)];
		
		for (int i = 0; i < 24; i++)
		{
			uint8_t randomVal = arc4random_uniform(128);
			[track.params setParam:i toValue:randomVal];
		}
	}
	
	
	
	return kit;
}

+(MDKit *)kitWithData:(NSData *)data
{
	return [MDKitParser kitFromSysexData:data];
}

- (id)init
{
	if(self = [super init])
	{
		char nameBytes[16];
		for (int i = 0; i < 16; i++) nameBytes[i] = 0;
		
		
		self.kitName = [NSData dataWithBytes:nameBytes length:16];
		[self initTracks];
		self.reverbSettings = [self defaultReverbSettings];
		self.delaySettings = [self defaultDelaySettings];
		self.eqSettings = [self defaultEQSettings];
		self.dynamicsSettings = [self defaultDynamicsSettings];
	
	}
	
	return self;
}

- (void)initTracks
{
	NSUInteger i = 0;
	
	self.tracks = [NSArray arrayWithObjects:
	 
				   [MDKitTrack trackWithIndex:i++],
				   [MDKitTrack trackWithIndex:i++],
				   [MDKitTrack trackWithIndex:i++],
				   [MDKitTrack trackWithIndex:i++],
				   
				   [MDKitTrack trackWithIndex:i++],
				   [MDKitTrack trackWithIndex:i++],
				   [MDKitTrack trackWithIndex:i++],
				   [MDKitTrack trackWithIndex:i++],
				   
				   [MDKitTrack trackWithIndex:i++],
				   [MDKitTrack trackWithIndex:i++],
				   [MDKitTrack trackWithIndex:i++],
				   [MDKitTrack trackWithIndex:i++],
				   
				   [MDKitTrack trackWithIndex:i++],
				   [MDKitTrack trackWithIndex:i++],
				   [MDKitTrack trackWithIndex:i++],
				   [MDKitTrack trackWithIndex:i++],
	 
	 nil];
}

- (NSMutableArray *)defaultReverbSettings
{
	return [NSMutableArray arrayWithObjects:
			[NSNumber numberWithInt:   0],
			[NSNumber numberWithInt:   0],
			[NSNumber numberWithInt:  64],
			[NSNumber numberWithInt:   0],
			
			[NSNumber numberWithInt:   0],
			[NSNumber numberWithInt: 127],
			[NSNumber numberWithInt: 127],
			[NSNumber numberWithInt:  96],
			nil];
}

- (NSMutableArray *)defaultDelaySettings
{
	return [NSMutableArray arrayWithObjects:
			[NSNumber numberWithInt:  32],
			[NSNumber numberWithInt:   0],
			[NSNumber numberWithInt:  32],
			[NSNumber numberWithInt:   0],
			
			[NSNumber numberWithInt:   0],
			[NSNumber numberWithInt: 127],
			[NSNumber numberWithInt:   0],
			[NSNumber numberWithInt:  96],
			nil];
}

- (NSMutableArray *)defaultEQSettings
{
	return [NSMutableArray arrayWithObjects:
			[NSNumber numberWithInt:  64],
			[NSNumber numberWithInt:  64],
			[NSNumber numberWithInt:  64],
			[NSNumber numberWithInt:  64],
			
			[NSNumber numberWithInt:  64],
			[NSNumber numberWithInt:  64],
			[NSNumber numberWithInt:  64],
			[NSNumber numberWithInt: 127],
			nil];
}

- (NSMutableArray *)defaultDynamicsSettings
{
	return [NSMutableArray arrayWithObjects:
			[NSNumber numberWithInt: 127],
			[NSNumber numberWithInt: 127],
			[NSNumber numberWithInt: 127],
			[NSNumber numberWithInt: 127],
			
			[NSNumber numberWithInt: 127],
			[NSNumber numberWithInt: 127],
			[NSNumber numberWithInt:   0],
			[NSNumber numberWithInt:   0],
			nil];
}

- (void)setReverbParam:(uint8_t)param toValue:(uint8_t)val
{
	[self.reverbSettings replaceObjectAtIndex:param withObject:@(val)];
}

- (void)setDelayParam:(uint8_t)param toValue:(uint8_t)val
{
	[self.delaySettings replaceObjectAtIndex:param withObject:@(val)];
}

- (void)setEQParam:(uint8_t)param toValue:(uint8_t)val
{
	[self.eqSettings replaceObjectAtIndex:param withObject:@(val)];
}

- (void)setDynamixParam:(uint8_t)param toValue:(uint8_t)val
{
	[self.dynamicsSettings replaceObjectAtIndex:param withObject:@(val)];
}

- (uint8_t)valueForReverbParam:(uint8_t)param
{
	return [[self.reverbSettings objectAtIndex:param] charValue];
}

- (uint8_t)valueForDelayParam:(uint8_t)param
{
	return [[self.delaySettings objectAtIndex:param] charValue];
}

- (uint8_t)valueForEQParam:(uint8_t)param
{
	return [[self.eqSettings objectAtIndex:param] charValue];
}

- (uint8_t)valueForDynamicsParam:(uint8_t)param
{
	return [[self.dynamicsSettings objectAtIndex:param] charValue];
}




@end





