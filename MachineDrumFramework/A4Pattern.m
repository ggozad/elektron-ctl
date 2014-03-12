//
//  A4Pattern.m
//  A4Sysex
//
//  Created by Jakob Penca on 3/28/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Pattern.h"
#import "A4PatternTrack.h"
#import "NSData+MachinedrumBundle.h"
#import "A4SysexHelper.h"
#import "MDMath.h"

@implementation A4Pattern

static inline uint8_t NumberOfUsedLocksInPattern(A4Pattern *instance)
{
	uint8_t num = 0;
	for (uint8_t i = 0; i < 0x80; i++)
	{
		A4LockRow row = instance->_locks->row[i];
		if(row.track != 0xFF && row.parameterID != 0xFF) num++;
	}
	return num;
}

static inline BOOL IsRowOccupiedButEmpty(A4Pattern *instance, uint8_t i)
{
	A4LockRow *row = & instance->_locks->row[i];
	for (uint8_t step = 0; step < 0x40; step++)
	{
		if(row->pattern[step] != 0xFF)
		{
			return NO;
		}
	}
	return YES;
}

static inline void EraseLock(A4Pattern *instance, uint8_t i)
{
	if(i >= 0x80) return;
	A4LockRow *row = & instance->_locks->row[i];
	row->track = 0xFF;
	row->parameterID = 0xFF;
	memset(&row->pattern, 0, 0x40);
}

static inline void EraseAndCleanupLock(A4Pattern *instance, uint8_t i)
{
	if(i > 127) return;
	
	A4LockRow *nextRow = & instance->_locks->row[i+1];
	A4LockRow *thisRow = & instance->_locks->row[i];
	memmove(thisRow, nextRow, sizeof(A4LockRow) * (127-i));
	EraseLock(instance, 127);
}

static inline BOOL PushRow(A4Pattern *pattern, uint8_t i, uint8_t amount)
{
	if(i > 126) return NO;
	if(amount == 0 || amount > 127-i) return NO;
	if(pattern->_locks->row[128-amount].parameterID != 0xFF) return NO;
	
	A4LockRow *row = & pattern->_locks->row[i];
	memmove(row+amount, row, sizeof(A4LockRow) * (128-i-amount));
	return YES;
}

static inline void InitRow(A4Pattern *pattern, uint8_t i, uint8_t param, uint8_t track, uint8_t trigs)
{
	A4LockRow *row = & pattern->_locks->row[i];
	row->track = track;
	row->parameterID = param;
	memset(&row->pattern, trigs, 0x40);
}

BOOL A4LocksForTrackAndStep(A4Pattern *pattern, uint8_t step, uint8_t track, A4PVal *locks, uint8_t *len)
{
	if(pattern == nil || track > 5 || step > 63) return NO;
	if(locks == NULL) return NO;
	
	uint8_t num = 0;
	for (uint8_t i = 0; i < 128; i++)
	{
		A4LockRow row = pattern->_locks->row[i];
		if(row.parameterID == A4NULL) break;
		if(row.track == track && row.pattern[step] != A4NULL)
		{
			uint8_t coarse = row.pattern[step];
			uint8_t fine = 0;
			
			if(A4ParamIs16Bit(row.parameterID))
			{
				A4LockRow fineRow = pattern->_locks->row[i+1];
				fine = fineRow.pattern[step];
			}
			
			
			A4PVal val = A4PValMake16(row.parameterID, coarse, fine);
			val = A4PValTranslateForSound(val);
			locks[num++] = val;
		}
	}
	*len = num;
	return num > 0;
}

BOOL A4LocksCreateForTrackAndStep(A4Pattern *pattern, uint8_t step, uint8_t track, A4PVal **pVals, uint8_t *len)
{
	if(pattern == nil || track > 5 || step > 63) return NO;
	if(*pVals != NULL) free(*pVals);
	uint8_t num = 0;
	A4PVal tmpVals[128];
	for (uint8_t i = 0; i < 128; i++)
	{
		A4LockRow row = pattern->_locks->row[i];
		if(row.parameterID == A4NULL) break;
		if(row.track == track && row.pattern[step] != A4NULL)
		{
			uint8_t coarse = row.pattern[step];
			uint8_t fine = 0;
			
			if(A4ParamIs16Bit(row.parameterID))
			{
				A4LockRow fineRow = pattern->_locks->row[i+1];
				fine = fineRow.pattern[step];
			}
			
			A4PVal val = A4PValMake16(row.parameterID, coarse, fine);
			val = A4PValTranslateForSound(val);
			tmpVals[num++] = val;
		}
	}
	
	if(num)
	{
		*pVals = (A4PVal *) malloc(sizeof(A4PVal) * num);
		*len = num;
		
		for (int i = 0; i < num; i++)
		{
			(*pVals)[i] = tmpVals[i];
		}
		return YES;
	}
	return NO;
}

void A4LocksRelease(A4PVal **locks)
{
	if(*locks != NULL) free(*locks);
}

uint8_t A4PatternPulsesPerStepForTimescale(A4PatternTimeScale timeScale)
{
	uint8_t num = 6;
	     if(timeScale == A4PatternTimeScale_1_8) num = 48;
	else if(timeScale == A4PatternTimeScale_1_4) num = 24;
	else if(timeScale == A4PatternTimeScale_1_2) num = 12;
	else if(timeScale == A4PatternTimeScale_3_4) num = 8;
	else if(timeScale == A4PatternTimeScale_1_1) num = 6;
	else if(timeScale == A4PatternTimeScale_3_2) num = 4;
	else if(timeScale == A4PatternTimeScale_2_1) num = 3;
	return num;
}

+ (A4Pattern *)defaultPattern
{
	A4Pattern *p = [self new];
	[p allocPayload];
	[p initTracks];
	[p initStructs];
	[p clear];
	return p;
}

- (BOOL)isDefaultPattern
{
	return [A4SysexHelper patternIsEqualToDefaultPattern:self];
}

- (BOOL)isEqualToPattern:(A4Pattern *)pattern
{
	return [A4SysexHelper pattern:self isEqualToPattern:pattern];
}

+ (instancetype)messageWithPayloadAddress:(char *)payload
{
	A4Pattern *pattern = [super messageWithPayloadAddress:payload];
	[pattern initTracks];
	[pattern initStructs];
	return pattern;
}

+ (instancetype)messageWithSysexData:(NSData *)data
{
	A4Pattern *p = [super messageWithSysexData:data];
	[p initTracks];
	[p initStructs];
	return p;
}

- (instancetype)init
{
	if(self = [super init])
	{
		self.type = A4SysexMessageID_Pattern;
	}
	return self;
}

- (void)setPayload:(char *)payload
{
	[super setPayload:payload];
	if(_payload)
	{
		[self initTracks];
		[self initStructs];
	}
}

- (void) allocPayload
{
	if(_payload && self.ownsPayload) free(_payload);
	self.payload = malloc(A4MessagePayloadLengthPattern);
	self.ownsPayload = YES;
}

- (void) initStructs
{
	self.locks = (A4LockStorage *) (_payload + 0xFEE);
}

- (void) setDefaultValuesForPayload
{
	if (!_payload) return;
	static dispatch_once_t onceToken;
    static NSData *patternData = nil;
    
	dispatch_once(&onceToken, ^{
        
		patternData = [NSData dataFromMachinedrumBundleResourceWithName:@"defaultPattern" ofType:@"payload"];
		
    });
	
	if(patternData != nil)
	{
		memmove(_payload, patternData.bytes, A4MessagePayloadLengthPattern);
	}
}

- (void) initTracks
{
	self.tracks = @[].mutableCopy;
	for (int i = 0; i < 6; i++)
	{
		char *trackPtr = _payload + 4 + i * A4MessagePayloadLengthTrack;
		A4PatternTrack *track = [A4PatternTrack trackWithPayloadAddress:trackPtr pattern:self];
		[_tracks addObject:track];
	}
}

- (A4PatternTrack *)track:(uint8_t)i
{
	if(i > 5) return nil;
	return _tracks[i];
}

- (A4PatternTrack *)track:(uint8_t)i copy:(BOOL)copy
{
	if(i > 5) return nil;
	if(copy)
	{
		A4PatternTrack *trackOrig = _tracks[i];
		A4PatternTrack *trackCopy = [A4PatternTrack new];
		
		char *payload = malloc(A4MessagePayloadLengthTrack);
		memmove(payload, trackOrig.payload, A4MessagePayloadLengthTrack);
		trackCopy.payload = payload;
		trackCopy.ownsPayload = YES;
		return trackCopy;
	}
	
	return _tracks[i];
}

- (A4PatternTrack *)copyTrack:(A4PatternTrack *)track toIndex:(uint8_t)i
{
	if(i > 5) return nil;
	
	NSAssert1(track.payload != NULL, @"track payload is NULL", nil);
	
	const char *trackPayloadBytes = track.payload;
	
	A4PatternTrack *targetTrack = _tracks[i];
	char *targetBytes = targetTrack.payload;
	
	if(targetBytes != trackPayloadBytes)
	{
		memmove(targetBytes, trackPayloadBytes, A4MessagePayloadLengthTrack);
	}
	
	return targetTrack;
}

- (void)clear
{
	[self setDefaultValuesForPayload];
}

- (uint8_t)kit
{
	return [self byteValueInPayloadAtIndex:0x30F2];
}

- (void)setKit:(uint8_t)kit
{
	[self setByteValue: kit & 0x7F inPayloadAtIndex:0x30F2];
}

- (void)setMasterLength:(UInt16)masterLength
{
	if(masterLength > 0x400) masterLength = 0x400;
//	if(masterLength < 1) masterLength = 1;
	
	UInt16 *ptr = (UInt16*)(_payload + 0x30EE);
	
	if([self timeMode] == A4PatternTimeModeNormal)
	{
		if(masterLength > 0x40) masterLength = 0x40;
		if(masterLength < 2) masterLength = 2;
		
		for (A4PatternTrack *track in _tracks)
		{
			track.settings->trackLength = masterLength;
		}
	}
	
	*ptr = CFSwapInt16HostToBig(masterLength);
}

- (UInt16)masterLength
{
	UInt16 *ptr = (UInt16*)(_payload + 0x30EE);
	return CFSwapInt16BigToHost(*ptr);
}

- (UInt16)masterChange
{
	UInt16 *ptr = (UInt16*)(_payload + 0x30F0);
	return CFSwapInt16BigToHost(*ptr);
}

- (void)setMasterChange:(UInt16)masterChange
{
	UInt16 *ptr = (UInt16*)(_payload + 0x30F0);
	*ptr = CFSwapInt16HostToBig(masterChange & 0x7FF);
}

- (void)setTimeMode:(A4PatternTimeMode)timeMode
{
	[self setByteValue: timeMode & 0x1 inPayloadAtIndex:0x30F4];
}

- (A4PatternTimeMode)timeMode
{
	return [self byteValueInPayloadAtIndex:0x30F4];
}

- (void)setTimeScale:(A4PatternTimeScale)timeScale
{
	[self setByteValue:timeScale inPayloadAtIndex:0x30F5];
}

- (A4PatternTimeScale)timeScale
{
	return [self byteValueInPayloadAtIndex:0x30F5];
}

- (void)setQuantizeAmount:(uint8_t)quantize
{
	[self setByteValue: quantize & 0x7F inPayloadAtIndex:0x30F6];
}

- (uint8_t)quantizeAmount
{
	return [self byteValueInPayloadAtIndex: 0x30F6];
}

- (uint8_t)numberOfUsedLocks
{
	return NumberOfUsedLocksInPattern(self);
}

- (NSArray *)soundLocks
{
	NSMutableArray *array = @[].mutableCopy;
	for (int trackIdx = 0; trackIdx < 6; trackIdx++)
	{
		A4PatternTrack *track = [self track:trackIdx];
		uint8_t *soundLocks = track.soundLocks;
		for (int step = 0; step < 64; step++)
		{
			uint8_t lock = soundLocks[step];
			if(lock != (uint8_t)A4NULL)
			{
				BOOL containsThisNumber = NO;
				for (NSNumber *n in array)
				{
					if(n.integerValue == lock)
					{
						containsThisNumber = YES;
						break;
					}
				}
				if(!containsThisNumber)
				{
					[array addObject:@(lock)];
				}
			}
		}
	}
	
	[array sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		
		if([obj1 integerValue] > [obj2 integerValue]) return NSOrderedDescending;
		if([obj1 integerValue] < [obj2 integerValue]) return NSOrderedAscending;
		return NSOrderedSame;
		
	}];
	
	return array;
}

- (void)replaceSoundLockIndex:(uint8_t)oldIndex withSoundLockIndex:(uint8_t)newIndex
{
	for (int trackIdx = 0; trackIdx < 6; trackIdx++)
	{
		A4PatternTrack *track = [self track:trackIdx];
		uint8_t *soundLocks = track.soundLocks;
		for (int step = 0; step < 64; step++)
		{
			if(soundLocks[step] == oldIndex) soundLocks[step] = newIndex;
		}
	}
}

- (void) setArpNoteLock:(uint8_t)n forNote: (uint8_t) i atStep:(uint8_t) step inTrack:(uint8_t)track
{
	if(track > 5) return;
	return [[self track:track] setArpNoteLock:n forNote:i atStep:step];
}

- (uint8_t) arpNoteLockForNote:(uint8_t) i atStep:(uint8_t) step inTrack:(uint8_t)track
{
	if(track > 5) return 0xFF;
	return [[self track:track] arpNoteLockForNote:i atStep:step];
}

- (void) setArpPatternState:(BOOL)state atStep:(uint8_t)step inTrack:(uint8_t)track
{
	[[self track:track] setArpPatternState:state atStep:step];
}

- (BOOL) arpPatternStateAtStep:(uint8_t)step inTrack:(uint8_t)track
{
	if(track > 5) return 0xFF;
	return [[self track:track] arpPatternStateAtStep:step];
}

- (void)setTrig:(A4Trig)trig atStep:(uint8_t)step inTrack:(uint8_t)track
{
	if(track > 5 || step > 63) return;
	[[self track:track] setTrig:trig atStep:step];
}

- (void)setTrig:(A4Trig)trig withLock:(A4PVal)lock atStep:(uint8_t)step inTrack:(uint8_t)track
{
	if(track > 5 || step > 63) return;
	[[self track:track] setTrig:trig atStep:step];
	[self setLock:lock atStep:step inTrack:track];
}

- (A4Trig)trigAtStep:(uint8_t)step inTrack:(uint8_t)track
{
	if(track > 5 || step > 63) return A4TrigMakeEmpty();
	return [[self track:track] trigAtStep:step];
}

- (void)clearTrigAtStep:(uint8_t)step inTrack:(uint8_t)track
{
	if(track > 5 || step > 63) return;
	[[self track:track] clearTrigAtStep:step];
}

- (void)clearTrack:(uint8_t)track
{
	if(track > 5) return;
	[[self track:track] clearAllTrigs];
}

- (A4PVal)setLock:(A4PVal)lock atStep:(uint8_t)step inTrack:(uint8_t)track
{
	if(step > 63) return A4PValMakeInvalid();
	if(track > 5) return A4PValMakeInvalid();
	
	A4Trig trig = [[self track:track] trigAtStep:step];
	
	if(lock.coarse != A4NULL && (trig.flags & A4TRIGFLAGS.TRIG) == 0 && (trig.flags & A4TRIGFLAGS.TRIGLESS) == 0)
	{
		trig = A4TrigMakeTrigless();
		[[self track:track ] setTrig:trig atStep:step];
	}
	
	uint8_t i = [self insertLock:A4PValTranslateForLock(lock) atStep:step inTrack:track];
	if(i != 0xFF) return lock; return A4PValMakeInvalid();
}

- (void)clearAllLocksAtStep:(uint8_t)step inTrack:(uint8_t)track
{
	if(step > 63) return;
	if(track > 5) return;
	
	
	A4PVal buf[128]; uint8_t len = 0;
	if(A4LocksForTrackAndStep(self, step, track, buf, &len))
	{
		for (int i = 0; i < len; i++)
		{
			[self clearLockForParam:buf[i].param atStep:step inTrack:track];
		}
	}
}

- (void)clearAllLocksForParam:(A4Param)param inTrack:(uint8_t)track
{
	if(track > 5) return;
	
	for (int i = 0; i < 128; i++)
	{
		A4LockRow *row = & _locks->row[i];
		
		if(row->track == track && row->parameterID == param)
		{
			EraseAndCleanupLock(self, i);
			i--;
		}
	}
}

- (BOOL)clearAllLocksInTrack:(uint8_t)track
{
	if(track > 5) return NO;

	for (int i = 0; i < 128; i++)
	{
		A4LockRow *row = & _locks->row[i];
		
		if(row->parameterID == 0xFF) return YES;
		
		if(row->track == track)
		{
			EraseAndCleanupLock(self, i);
			i--;
		}
	}
	
	return YES;
}

- (BOOL)clearAllLocks
{
	for (int i = 0; i < 128; i++)
	{
		EraseLock(self, i);
	}
	return YES;
}

- (A4PVal)lockForParam:(A4Param)param atStep:(uint8_t)step inTrack:(uint8_t)track
{
	if(track > 5) return A4PValMakeInvalid();
	if(step > 63) return A4PValMakeInvalid();
	
	for (int i = 0; i < 128; i++)
	{
		A4LockRow *row = & _locks->row[i];
		if(row->parameterID == A4NULL) return A4PValMakeInvalid();
		if(row->track == track && row->parameterID == param)
		{
			if(row->pattern[step] == A4NULL) return A4PValMakeInvalid();
			
			uint8_t coarse = row->pattern[step];
			uint8_t fine = 0;
			
			if(A4ParamIs16Bit(row->parameterID) && i < 127)
			{
				A4LockRow fineRow = _locks->row[i+1];
				fine = fineRow.pattern[step];
			}
			
			A4PVal val = A4PValMake16(row->parameterID, coarse, fine);
			val = A4PValTranslateForSound(val);
			return val;
		}
	}
	
	return A4PValMakeInvalid();
}

- (void)clearLockForParam:(A4Param)param atStep:(uint8_t)step inTrack:(uint8_t)track
{
	if(track > 5 || step > 63) return;
	A4PVal lock = A4PValMakeClear(param);
	[self setLock:lock atStep:step inTrack:track];
}

- (uint8_t) insertLock:(A4PVal )lock atStep:(uint8_t) step inTrack:(uint8_t) track
{
	if(track  > 5 || step > 63) return 0xFF;
	BOOL is16Bit = A4ParamIs16Bit(lock.param);
	
	for (int i = 0; i < 128; i++)
	{
		A4LockRow *row = & _locks->row[i];
		
		if(row->parameterID == 0x80) continue;
		
		if(row->parameterID == 0xFF && lock.coarse != 0xFF)
		{
			if(is16Bit)
			{
				if(PushRow(self, i, 2))
				{
					InitRow(self, i, lock.param, track, 0xFF);
					InitRow(self, i+1, 0x80, 0x80, 0xFF);
					row->pattern[step] = lock.coarse;
					A4LockRow *fineRow = row+1;
					fineRow->pattern[step] = lock.fine;
					return i;
				}
			}
			else
			{
				InitRow(self, i, lock.param, track, 0xFF);
				row->pattern[step] = lock.coarse;
				return i;
			}
		}
		if(row->parameterID == lock.param && row->track == track) // lock exists
		{
			row->pattern[step] = lock.coarse;
			
			if(is16Bit)
			{
				A4LockRow *fineRow = row+1;
				if(fineRow->parameterID == 0x80)
				{
					(row+1)->pattern[step] = lock.fine;
				}
			}
			
			if(lock.coarse == A4NULL && IsRowOccupiedButEmpty(self, i))
			{
				EraseAndCleanupLock(self, i);
				if(is16Bit && i < 127 && row->parameterID == 0x80)
				{
					EraseAndCleanupLock(self, i);
				}
				return i;
			}
			return i;
		}
		if(((row->parameterID == lock.param && row->track > track) ||
		   (row->parameterID > lock.param)))
		{
			if(is16Bit && PushRow(self, i, 2))
			{
				InitRow(self, i, lock.param, track, 0xFF);
				InitRow(self, i+1, 0x80, 0x80, 0xFF);
				row->pattern[step] = lock.coarse;
				A4LockRow *fineRow = row+1;
				fineRow->pattern[step] = lock.fine;
				return i;
			}
			else if (!is16Bit && PushRow(self, i, 1))
			{
				InitRow(self, i, lock.param, track, 0xFF);
				row->pattern[step] = lock.coarse;
				return i;
			}
		}
	}
	return 0xFF;
}

- (void)shiftTrack:(uint8_t)trackIdx steps:(int8_t)shift
{
	if(trackIdx > 5 || shift == 0) return;
	
	A4PVal locksBuf[128]; uint8_t locksLen = 0;
	A4PatternTrack *track = [self track:trackIdx];
	int trackLen = track.settings->trackLength;
	
	A4Pattern *patternCopy = [A4Pattern messageWithSysexData:self.sysexData];
	
	for(int stepIdx = 0; stepIdx < trackLen; stepIdx++)
	{
		[self clearTrigAtStep:stepIdx inTrack:trackIdx];
	}
	
	for(int stepIdx = 0; stepIdx < trackLen; stepIdx++)
	{
		int newStepIdx = mdmath_wrap(stepIdx+shift, 0, trackLen-1);
		
		A4Trig trig = [patternCopy trigAtStep:stepIdx inTrack:trackIdx];
		[self setTrig:trig atStep:newStepIdx inTrack:trackIdx];
		
		if(A4LocksForTrackAndStep(patternCopy, stepIdx, trackIdx, locksBuf, &locksLen))
		{
			for(uint8_t lockIdx = 0; lockIdx < locksLen; lockIdx++)
			{
				[self setLock:locksBuf[lockIdx] atStep:newStepIdx inTrack:trackIdx];
			}
		}
	}
}



@end
