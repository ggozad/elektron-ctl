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

+ (id)kitWithRandomParametersAndDrumModels
{
	MDKit *kit = [MDKit new];
	
	for (MDKitTrack *track in kit.tracks)
	{
		uint8_t availableSynthesisMethods[] = {16,32,48,64};
		int method = arc4random_uniform(4);
		
		uint8_t chosenMethod = availableSynthesisMethods[method];
		uint8_t chosenMachineOffset = 0;
		uint8_t maxOffset = 0;
		
		if(chosenMethod == 16) maxOffset = 12;
		if(chosenMethod == 32) maxOffset =  7;
		if(chosenMethod == 48) maxOffset = 15;
		if(chosenMethod == 64) maxOffset =  8;
		
		chosenMachineOffset = arc4random_uniform(maxOffset+1);
		
		track.drumModel = [NSNumber numberWithInt:chosenMethod + chosenMachineOffset];
		
		for (int i = 0; i < 24; i++)
		{
			uint8_t randomVal = arc4random_uniform(128);
			[track.params setParam:i toValue:randomVal];
		}
	}
	
	
	
	return kit;
}

+(id)kitWithData:(NSData *)data
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





