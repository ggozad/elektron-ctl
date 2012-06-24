//
//  MDKit.m
//  sysexingApp
//
//  Created by Jakob Penca on 5/20/12.
//
//

#import "MDKit.h"
#import "MDMidiFoundation.h"
#import "MDSysexUtil.h"
#import "MDKitParser.h"


@interface MDKit()

- (NSArray *)defaultReverbSettings;
- (NSArray *)defaultDelaySettings;
- (NSArray *)defaultEQSettings;
- (NSArray *)defaultDynamicsSettings;
- (void) initTracks;



@end

@implementation MDKit
@synthesize tracks, kitName, originalPosition;



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

- (NSArray *)defaultReverbSettings
{
	return [NSArray arrayWithObjects:
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

- (NSArray *)defaultDelaySettings
{
	return [NSArray arrayWithObjects:
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

- (NSArray *)defaultEQSettings
{
	return [NSArray arrayWithObjects:
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

- (NSArray *)defaultDynamicsSettings
{
	return [NSArray arrayWithObjects:
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




@end





