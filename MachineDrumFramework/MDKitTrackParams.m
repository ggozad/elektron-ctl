//
//  MDTrackParams.m
//  sysexingApp
//
//  Created by Jakob Penca on 5/20/12.
//
//

#import "MDKitTrackParams.h"

@interface MDKitTrackParams()
@property (strong, nonatomic) NSArray *params;
- (void) initDefaultParams;
@end



@implementation MDKitTrackParams
@synthesize params;

- (id)init
{
	if(self = [super init])
	{
		[self initDefaultParams];
	}
	return self;
}


- (void)setParam:(uint8_t)i toValue:(uint8_t)val
{
	if(i >= 24) return;
	NSNumber *n = [NSNumber numberWithInt:val];
	[(NSMutableArray *)self.params replaceObjectAtIndex:i withObject:n];
}

- (uint8_t)valueForParam:(uint8_t)i
{
	if(i < 24) return (uint8_t) [[self.params objectAtIndex:i] intValue];
	else return 0;
}

- (void)initDefaultParams
{
	self.params = [NSMutableArray arrayWithObjects:
				   [NSNumber numberWithInt:  64],
				   [NSNumber numberWithInt:  64],
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt:   0],
				   
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt:  64],
				   [NSNumber numberWithInt:  64],
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt: 127],
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt:   0],
				   
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt: 127],
				   [NSNumber numberWithInt:  64],
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt:  64],
				   [NSNumber numberWithInt:   0],
				   [NSNumber numberWithInt:   0],
				   nil];
}

@end
