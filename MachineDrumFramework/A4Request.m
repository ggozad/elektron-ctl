//
//  A4Request.m
//  MachineDrumFramework
//
//  Created by Jakob Penca on 09/12/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "A4Request.h"
#import "MDMachinedrumPublic.h"
#import "A4Queues.h"

#define A4RequestKeyStringPattern		@"pat"
#define A4RequestKeyStringKit			@"kit"
#define A4RequestKeyStringSound			@"snd"
#define A4RequestKeyStringGlobal		@"glo"
#define A4RequestKeyStringSettings		@"set"
#define A4RequestKeyStringSong			@"son"

NSUInteger PayloadLenForRequestID(A4SysexRequestID id)
{
	NSUInteger len = 0;
	
	switch (id)
	{
		case A4SysexRequestID_Global:
		case A4SysexRequestID_Global_X:
		{
			len = A4MessagePayloadLengthGlobal;
			break;
		}
		case A4SysexRequestID_Settings:
		case A4SysexRequestID_Settings_X:
		{
			len = A4MessagePayloadLengthSettings;
			break;
		}
		case A4SysexRequestID_Sound:
		case A4SysexRequestID_Sound_X:
		{
			len = A4MessagePayloadLengthSound;
			break;
		}
		case A4SysexRequestID_Kit:
		case A4SysexRequestID_Kit_X:
		{
			len = A4MessagePayloadLengthKit;
			break;
		}
		case A4SysexRequestID_Pattern:
		case A4SysexRequestID_Pattern_X:
		{
			len = A4MessagePayloadLengthPattern;
			break;
		}
		case A4SysexRequestID_Song:
		case A4SysexRequestID_Song_X:
		{
			len = A4MessagePayloadLengthSong;
			break;
		}
		default:
			break;
	}
	
	return len;
}

A4SysexRequestID A4SysexRequestIDForResponseID(A4SysexMessageID id)
{
	switch (id)
	{
		case A4SysexMessageID_Global		: return A4SysexRequestID_Global;
		case A4SysexMessageID_Global_X		: return A4SysexRequestID_Global_X;
		case A4SysexMessageID_Settings		: return A4SysexRequestID_Settings;
		case A4SysexMessageID_Settings_X	: return A4SysexRequestID_Settings_X;
		case A4SysexMessageID_Pattern		: return A4SysexRequestID_Pattern;
		case A4SysexMessageID_Pattern_X		: return A4SysexRequestID_Pattern_X;
		case A4SysexMessageID_Kit			: return A4SysexRequestID_Kit;
		case A4SysexMessageID_Kit_X			: return A4SysexRequestID_Kit_X;
		case A4SysexMessageID_Sound			: return A4SysexRequestID_Sound;
		case A4SysexMessageID_Sound_X		: return A4SysexRequestID_Sound_X;
		case A4SysexMessageID_Song			: return A4SysexRequestID_Song;
		case A4SysexMessageID_Song_X		: return A4SysexRequestID_Song_X;
		default:break;
	}
	return 0;
}

A4SysexMessageID A4SysexResponseIDForRequestID(A4SysexRequestID id)
{
	switch (id)
	{
		case A4SysexRequestID_Global		: return A4SysexMessageID_Global;
		case A4SysexRequestID_Global_X		: return A4SysexMessageID_Global_X;
		case A4SysexRequestID_Settings		: return A4SysexMessageID_Settings;
		case A4SysexRequestID_Settings_X	: return A4SysexMessageID_Settings_X;
		case A4SysexRequestID_Pattern		: return A4SysexMessageID_Pattern;
		case A4SysexRequestID_Pattern_X		: return A4SysexMessageID_Pattern_X;
		case A4SysexRequestID_Kit			: return A4SysexMessageID_Kit;
		case A4SysexRequestID_Kit_X			: return A4SysexMessageID_Kit_X;
		case A4SysexRequestID_Sound			: return A4SysexMessageID_Sound;
		case A4SysexRequestID_Sound_X		: return A4SysexMessageID_Sound_X;
		case A4SysexRequestID_Song			: return A4SysexMessageID_Song;
		case A4SysexRequestID_Song_X		: return A4SysexMessageID_Song_X;
		default:break;
	}
	return 0;
}

NSInteger CreateIdent()
{
	static A4RequestHandle i = 0;
	i++; if (i == NSIntegerMax) i -= NSIntegerMax-1;
	return i;
}

typedef struct Key
{
	A4SysexRequestID id;
	uint8_t pos;
	uint8_t activeSoundTracknumber;
}
Key;

Key KeyMake(A4SysexRequestID id, uint8_t pos)
{
	Key key;
	key.id = id;
	key.pos = pos;
	key.activeSoundTracknumber = A4NULL;
	return key;
}

Key KeyMakeActiveSound(A4SysexRequestID id, uint8_t pos, uint8_t track)
{
	Key key = KeyMake(id, pos);
	key.activeSoundTracknumber = track;
	return key;
}

Key KeyMakeInvalid()
{
	Key key;
	key.pos = A4NULL;
	key.id = A4SysexRequestID_NULL;
	key.activeSoundTracknumber = A4NULL;
	return key;
}

BOOL KeyIsValid(Key key)
{
	if(key.id < A4SysexRequestID_Kit) return NO;
	if(key.id > A4SysexRequestID_Global_X) return NO;
	if(key.pos > 3 && key.id == A4SysexRequestID_Global) return NO;
	if(key.pos > 0 && key.id == A4SysexRequestID_Settings) return NO;
	if(key.pos > 15 && key.id == A4SysexRequestID_Song) return NO;
	if(key.pos > 127 && key.id == A4SysexRequestID_Pattern) return NO;
	if(key.pos > 127 && key.id == A4SysexRequestID_Kit) return NO;
	if(key.pos > 127 && key.id == A4SysexRequestID_Sound) return NO;
	
	if(key.pos != A4NULL &&
	   (key.id == A4SysexRequestID_Kit_X ||
		key.id == A4SysexRequestID_Pattern_X ||
		key.id == A4SysexRequestID_Song_X ||
		key.id == A4SysexRequestID_Global_X ||
		key.id == A4SysexRequestID_Settings_X)) return NO;
	
	if(key.id == A4SysexRequestID_Sound_X && key.activeSoundTracknumber > 3) return NO;
	if(key.id == A4SysexRequestID_Sound_X && key.pos != A4NULL) return NO;
	return YES;
}

BOOL KeysAreEqual(Key a, Key b)
{
	if( ! KeyIsValid(a) || ! KeyIsValid(b)) return NO;
	if(a.id == b.id && a.pos == b.pos && a.activeSoundTracknumber == b.activeSoundTracknumber) return YES;
	return NO;
}

@interface NSValue(Key)
+(instancetype)valueWithKey:(Key)key;
- (Key)keyValue;
@end

@implementation NSValue(Key)
+(instancetype)valueWithKey:(Key)key
{
	return [NSValue valueWithBytes:&key objCType:@encode(Key)];
}

- (Key)keyValue
{
	Key key; [self getValue:&key]; return key;
}
@end


@interface A4Transaction : NSObject
@property (nonatomic) uint16_t options;
@property (nonatomic) dispatch_queue_t completionQueue;
@property (nonatomic, copy) void (^completionHandler)(NSDictionary *);
@property (nonatomic, copy) void (^errorHandler)(NSError *);
@property (nonatomic, strong) NSMutableArray *keysToProcess;
@property (nonatomic, strong) NSMutableDictionary *completedSubRequests;
@property (nonatomic) A4RequestHandle ident;
@property (nonatomic, weak) id<A4RequestDelegate> delegate;
@property (nonatomic) NSUInteger completedPayloadByteCount, totalPayloadByteCount;
@end

@implementation A4Transaction
- (id)init
{
	if (self = [super init])
	{
		self.completedSubRequests = @{}.mutableCopy;
		self.keysToProcess = @[].mutableCopy;
	}
	return self;
}
@end

@interface A4Request()
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic) BOOL isListeningForSysex;
@property (nonatomic) A4Transaction *currentTransaction;
@property (nonatomic) NSMutableArray *currentTransactionKeysAddedDuringRequest;
@property (nonatomic) NSMutableArray *totalKeysForCurrentTransaction;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@end

@implementation A4Request

static A4Request *_default = nil;

+ (instancetype)sharedInstance
{
	if(_default != nil) return _default;
	static dispatch_once_t safer;
	dispatch_once(&safer, ^(void)
				  {
					  _default = [[self alloc] init];
				  });
	return _default;
}

- (id)init
{
	if(self = [super init])
	{
		self.queue = @[].mutableCopy;
		self.currentTransactionKeysAddedDuringRequest = @[].mutableCopy;
	}
	return self;
}


+ (BOOL)cancelRequest:(NSInteger)handle
{
	@synchronized(self)
	{
		__block BOOL didRemove = NO;
		dispatch_sync([A4Queues sysexQueue], ^{
			
			A4Transaction *tToRemove = nil;
			for (A4Transaction *t in [[self sharedInstance] queue])
			{
				if (t.ident == handle)
				{
					tToRemove = t; break;
				}
			}
			
			if(tToRemove)
			{
				[[self sharedInstance] removeTransactionFromQueue:tToRemove];
				didRemove = YES;
			}
			
		});
		
		return didRemove;
	}
}

+(void)cancelAllRequests
{
	@synchronized(self)
	{
		dispatch_async([A4Queues sysexQueue], ^{
			
			[[self sharedInstance] stopListeningForSysex];
			
			for (A4Transaction *t in [[self sharedInstance] queue])
			{
				[[self sharedInstance] dispatchErrorHandlerForTransaction:t withError:
				 [NSError errorWithDomain:@"cancelled" code:-1 userInfo:nil]];
			}
			
			
			[[[self sharedInstance] queue] removeAllObjects];
			
		});
	}
}

+ (NSInteger)requestWithKeys:(NSArray *)keys
		   completionHandler:(void (^)(NSDictionary *dict))completionHandler
				errorHandler:(void (^)(NSError *err))errorHandler
{
	return [self requestWithKeys:keys
						 options:0
						delegate:nil
			   completionHandler:completionHandler
					errorHandler:errorHandler];
}

+ (NSInteger)requestWithKeys:(NSArray *)keys
					 options:(A4RequestOptions)optionsBitmask
					delegate:(id<A4RequestDelegate>)delegate
		   completionHandler:(void (^)(NSDictionary *dict))completionHandler
				errorHandler:(void (^)(NSError *err))errorHandler
{
	@synchronized(self)
	{
		return [self requestWithKeys:keys
							 options:optionsBitmask
							priority:A4RequestPriorityDefault
							delegate:delegate
					 completionQueue:dispatch_get_main_queue()
				   completionHandler:completionHandler
						errorHandler:errorHandler];
	}
}


+ (NSInteger)requestWithKeys:(NSArray *)keys
					 options:(A4RequestOptions)optionsBitmask
					priority:(A4RequestPriority)priority
					delegate:(id<A4RequestDelegate>)delegate
			 completionQueue:(dispatch_queue_t)queue
		   completionHandler:(void (^)(NSDictionary *dict))completionHandler
				errorHandler:(void (^)(NSError *err))errorHandler
{
	@synchronized(self)
	{
		if(! completionHandler) return 0;
		if(! errorHandler) return 0;
		if(! queue) return 0;
		
		NSMutableArray *allKeys = @[].mutableCopy;
		if(keys.count)
		{
			NSArray *parsed = [self keysParsedFromUserKeyStringsArray:keys];
			if(parsed)[allKeys addObjectsFromArray:parsed];
			else
			{
				A4Transaction *transaction = [A4Transaction new];
				transaction.completionQueue = queue;
				transaction.completionHandler = completionHandler;
				transaction.errorHandler = errorHandler;
				transaction.options = optionsBitmask;
				transaction.ident = 0;
				transaction.delegate = delegate;
				
				[[self sharedInstance] dispatchErrorHandlerForTransaction:transaction
																withError:[NSError errorWithDomain:@"keys are invalid" code:-1 userInfo:@{@"keys" : [keys copy]}]];
				return 0;
			}
		}
		
		NSInteger handle = CreateIdent();
		
		void (^theBlock)() = ^void()
		{
			A4Transaction *transaction = [A4Transaction new];
			transaction.completionQueue = queue;
			transaction.completionHandler = completionHandler;
			transaction.errorHandler = errorHandler;
			transaction.options = optionsBitmask;
			transaction.ident = handle;
			transaction.delegate = delegate;
			
			if(allKeys)
			{
				[transaction.keysToProcess addObjectsFromArray:allKeys];
			}
			
			if(priority == A4RequestPriorityDefault)
			{
				[[self sharedInstance] addTransactionToQueueTail:transaction];
			}
			
			if([[[self sharedInstance] queue] count] == 1 &&
			   ! [[self sharedInstance] currentTransaction])
			{
				[[self sharedInstance] dequeue];
			}
			
		};
		
		dispatch_queue_t mainQueue = dispatch_get_main_queue();
		if(mainQueue != [A4Queues sysexQueue])
		{
			dispatch_async([A4Queues sysexQueue], theBlock);
		}
		else
		{
			dispatch_async(mainQueue, theBlock);
		}
		
		return handle;
	}
}

+ (NSArray *) keysParsedFromUserKeyStringsArray:(NSArray *)keyStrings
{
	NSMutableArray *array = @[].mutableCopy;
	for (NSString *str in keyStrings)
	{
		NSString *cleaned = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
		NSArray *splits = [cleaned componentsSeparatedByString:@"|"];
		for (NSString *keyString in splits)
		{
			Key key = [self keyWithKeyString:keyString];
			if(KeyIsValid(key))
			{
				[self addKey:key toKeysArray:array];
			}
			else
			{
				return nil;
			}
		}
	}
	return array;
}

+ (BOOL) addKey:(Key)newKey toKeysArray:(NSMutableArray *)keys
{
	BOOL doesAlreadyContainKey = NO;
	
	for (NSValue *keyValue in keys)
	{
		Key k = keyValue.keyValue;
		if (KeysAreEqual(k, newKey)){ doesAlreadyContainKey = YES; break; }
	}
	
	if(!doesAlreadyContainKey)
	{
		[keys addObject:[NSValue valueWithKey:newKey]];
	}
	
	return ! doesAlreadyContainKey;
}


- (void) inflateOptionsKeysInCurrentTransaction
{
	A4Transaction *t = self.currentTransaction;
	if(! t) return;
	
	if(t.options & A4RequestOptionsAllSounds)
	{
		for (int i = 0; i < 128; i++)
		{
			Key key = KeyMake(A4SysexRequestID_Sound, i);
			[A4Request addKey:key toKeysArray: t.keysToProcess];
		}
	}
	if(t.options & A4RequestOptionsAllPatterns)
	{
		for (int i = 0; i < 128; i++)
		{
			Key key = KeyMake(A4SysexRequestID_Pattern, i);
			[A4Request addKey:key toKeysArray: t.keysToProcess];
		}
	}
	if(t.options & A4RequestOptionsAllKits)
	{
		for (int i = 0; i < 128; i++)
		{
			Key key = KeyMake(A4SysexRequestID_Kit, i);
			[A4Request addKey:key toKeysArray: t.keysToProcess];
		}
	}
	if(t.options & A4RequestOptionsAllGlobals)
	{
		for (int i = 0; i < 4; i++)
		{
			Key key = KeyMake(A4SysexRequestID_Global, i);
			[A4Request addKey:key toKeysArray: t.keysToProcess];
		}
	}
	if(t.options & A4RequestOptionsAllSettings)
	{
		Key key = KeyMake(A4SysexRequestID_Settings, 0);
		[A4Request addKey:key toKeysArray: t.keysToProcess];
	}
}


- (void) cancelTimeout
{
	dispatch_async(dispatch_get_main_queue(), ^{
		
		if(self.timeoutTimer)
		{
//			DLog(@"cancel timeout");
			[self.timeoutTimer invalidate];
			self.timeoutTimer = nil;
		}
	});
}

- (void) startTimeout
{
	[self cancelTimeout];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
									selector:@selector(handleTimeoutTimer:) userInfo:nil repeats:NO];
		
	});
}

- (void) handleTimeoutTimer:(NSTimer *)timer // gets called on main queue!
{
	if(timer == self.timeoutTimer)
	{
		self.timeoutTimer = nil;
	}
	
	dispatch_async([A4Queues sysexQueue], ^{
		
		if(_currentTransaction)
		{
			[A4Request cancelAllRequests];
			
			NSMutableArray *keys = @[].mutableCopy;
			for (NSValue *keyVal in self.currentTransaction.keysToProcess)
			{
				NSString *keyString = [A4Request keyStringWithKey:keyVal.keyValue];
				if(keyString)
				{
					[keys addObject:keyString];
				}
				else
				{
					[keys addObject:@"INVALID KEY"];
				}
			}
			
			[self cancelCurrentTransactionWithError:
			 [NSError errorWithDomain:@"timeout" code:-1 userInfo:@{@"unprocessed keys" : keys}]];
		}
		
	});
}

- (void) dequeue
{
	if(!self.queue.count)
	{
		[self stopListeningForSysex];
		return;
	}
	if(self.currentTransaction) return;
	
	[self startListeningForSysex];
	A4Transaction *t = self.queue[0];
	[self.queue removeObject:t];
	[self startTransaction:t];
}

- (void) startTransaction:(A4Transaction *)t
{
	if(self.currentTransaction) return;
	
	self.currentTransaction = t;
	
	if(! [[MDMIDI sharedInstance] a4MidiDestination] ||
	   ! [[MDMIDI sharedInstance] a4MidiSource])
	{
		[self cancelCurrentTransactionWithError:[NSError errorWithDomain:@"no connection" code:-1 userInfo:nil]];
		return;
	}
	
	if([self.currentTransaction.delegate respondsToSelector:@selector(a4requestDidBeginRequestWithHandle:)])
	{
		A4RequestHandle handle = self.currentTransaction.ident;
		
		dispatch_async(self.currentTransaction.completionQueue, ^{
			
			[self.currentTransaction.delegate a4requestDidBeginRequestWithHandle:handle];
			
		});
	}
	
	[self inflateOptionsKeysInCurrentTransaction];
	self.totalKeysForCurrentTransaction = self.currentTransaction.keysToProcess.mutableCopy;
	self.currentTransactionKeysAddedDuringRequest = @[].mutableCopy;
	
	[self addCurrentKeysToTotalByteCount];
	
	if(self.currentTransaction.options & A4RequestOptions_SAFER_)
	{
		[self processFirstKeyInCurrentTransaction];
	}
	else
	{
		[self processKeysInCurrentTransaction];
	}
}

- (void) addCurrentKeysToTotalByteCount
{
	for(NSValue *v in _currentTransaction.keysToProcess)
	{
		Key key = v.keyValue;
		if(KeyIsValid(key))
		{
			self.currentTransaction.totalPayloadByteCount += PayloadLenForRequestID(key.id);
		}
	}
}

- (void) processKeysInCurrentTransaction
{
	NSAssert(_currentTransaction, @"no transaction!");
	NSAssert(_currentTransaction.keysToProcess.count, @"no keys to process!");
	
	for(NSValue *v in _currentTransaction.keysToProcess)
	{
		Key key = v.keyValue;
		if(KeyIsValid(key))
		{
			[self requestObjectWithKey:key];
		}
	}
	
	[self startTimeout];
}

- (void) processFirstKeyInCurrentTransaction
{
	NSAssert(_currentTransaction, @"no transaction!");
	NSAssert(_currentTransaction.keysToProcess.count, @"no key to process!");
	
	NSValue *val = _currentTransaction.keysToProcess[0];
	Key key = val.keyValue;
	if(KeyIsValid(key))
	{
		[self requestObjectWithKey:key];
		[self startTimeout];
	}
	else
	{
		[self cancelCurrentTransactionWithError:[NSError errorWithDomain:@"invalid key" code:-1 userInfo:nil]];
	}
}

- (void) addKeyToCurrentTransaction:(Key)newKey
{
	NSAssert(KeyIsValid(newKey), @"key must not be invalid!");
	NSAssert(self.currentTransaction, @"no current transaction!");
	
	[A4Request addKey:newKey toKeysArray:self.currentTransactionKeysAddedDuringRequest];
}


- (void) requestObjectWithKey:(Key)key
{
	if(! KeyIsValid(key))
	{
		[self cancelCurrentTransactionWithError:
		 [NSError errorWithDomain:@"key is invalid" code:-1 userInfo:@{@"key" : [A4Request keyStringWithKey:key]}]];
		return;
	}
	
	uint8_t id = key.id;
	uint8_t pos = key.pos;
	if(pos == A4NULL) pos = 0;
	if(key.id == A4SysexRequestID_Sound_X && key.activeSoundTracknumber < 4) pos = key.activeSoundTracknumber;
	uint8_t request[] = {0xF0, 0x00, 0x20, 0x3C, 0x06, 0x00, id, 0x01, 0x01, pos, 0x00, 0x00, 0x00, 0x05, 0xF7};
	[[[MDMIDI sharedInstance] a4MidiDestination] sendBytes:request size:15];
}


+ (NSString *)keyTypeStringWithRequestID:(uint8_t)id
{
	if(id == A4SysexRequestID_Kit || id == A4SysexRequestID_Kit_X)				return A4RequestKeyStringKit;
	if(id == A4SysexRequestID_Pattern || id == A4SysexRequestID_Pattern_X)		return A4RequestKeyStringPattern;
	if(id == A4SysexRequestID_Sound || id == A4SysexRequestID_Sound_X)			return A4RequestKeyStringSound;
	if(id == A4SysexRequestID_Song || id == A4SysexRequestID_Song_X)			return A4RequestKeyStringSong;
	if(id == A4SysexRequestID_Settings || id == A4SysexRequestID_Settings_X)	return A4RequestKeyStringSettings;
	if(id == A4SysexRequestID_Global || id == A4SysexRequestID_Global_X)		return A4RequestKeyStringGlobal;
	
	return nil;
}

+ (uint8_t)requestIDWithKeyTypeString:(NSString *)keyType temp:(BOOL)temp
{
	if(!temp)
	{
		if([keyType isEqualToString:A4RequestKeyStringKit])			return A4SysexRequestID_Kit;
		if([keyType isEqualToString:A4RequestKeyStringPattern])		return A4SysexRequestID_Pattern;
		if([keyType isEqualToString:A4RequestKeyStringSound])		return A4SysexRequestID_Sound;
		if([keyType isEqualToString:A4RequestKeyStringSong])		return A4SysexRequestID_Song;
		if([keyType isEqualToString:A4RequestKeyStringGlobal])		return A4SysexRequestID_Global;
		if([keyType isEqualToString:A4RequestKeyStringSettings])	return A4SysexRequestID_Settings;
	}
	else
	{
		if([keyType isEqualToString:A4RequestKeyStringKit])			return A4SysexRequestID_Kit_X;
		if([keyType isEqualToString:A4RequestKeyStringPattern])		return A4SysexRequestID_Pattern_X;
		if([keyType isEqualToString:A4RequestKeyStringSound])		return A4SysexRequestID_Sound_X;
		if([keyType isEqualToString:A4RequestKeyStringSong])		return A4SysexRequestID_Song_X;
		if([keyType isEqualToString:A4RequestKeyStringGlobal])		return A4SysexRequestID_Global_X;
		if([keyType isEqualToString:A4RequestKeyStringSettings])	return A4SysexRequestID_Settings_X;
	}
	
	return 0;
}

+ (Key) keyWithKeyString:(NSString *)str
{
	NSArray *tokens = [self tokensForKeyString:str];
	if(! tokens ) return KeyMake(A4SysexRequestID_NULL, A4NULL);
	uint8_t position = [tokens[1] intValue];
	uint8_t activeSoundTrack = A4NULL;
	
	if(position == 0 && [tokens[1] isEqualToString:@"x"])
	{
		 position = A4NULL;
		 if(tokens.count == 3)
		 {
			 activeSoundTrack = [tokens[2] intValue];
		 }
	}
	if(activeSoundTrack != A4NULL)
	{
		return KeyMakeActiveSound([self requestIDWithKeyTypeString:tokens[0] temp:position == A4NULL], position, activeSoundTrack);
	}
	else
	{
		return KeyMake([self requestIDWithKeyTypeString:tokens[0] temp: position == A4NULL], position);
	}
}

+ (NSString *) keyStringWithKey:(Key)key
{
	if( ! KeyIsValid(key)) return nil;
	if(key.pos == A4NULL)
	{
		if(key.id == A4SysexRequestID_Sound_X && key.activeSoundTracknumber != A4NULL)
		{
			return [NSString stringWithFormat:@"%@.x.%d", [self keyTypeStringWithRequestID:key.id], key.activeSoundTracknumber];
		}
		else
		{
			return [NSString stringWithFormat:@"%@.x", [self keyTypeStringWithRequestID:key.id]];
		}
	}
	else
	{
		return [NSString stringWithFormat:@"%@.%d", [self keyTypeStringWithRequestID:key.id], key.pos];
	}
}

+ (NSArray *) tokensForKeyString:(NSString *) key
{
	NSArray *tokens = [key componentsSeparatedByString:@"."];
	if(! tokens) return nil;
	if(! tokens.count || tokens.count > 3) return nil;
	NSMutableArray *parsed = @[].mutableCopy;
	
	BOOL typeOkay = NO;
	if([tokens[0] isEqualToString:A4RequestKeyStringKit]		||
	   [tokens[0] isEqualToString:A4RequestKeyStringPattern]	||
	   [tokens[0] isEqualToString:A4RequestKeyStringSound]	||
	   [tokens[0] isEqualToString:A4RequestKeyStringSong]		||
	   [tokens[0] isEqualToString:A4RequestKeyStringGlobal]	||
	   [tokens[0] isEqualToString:A4RequestKeyStringSettings])
	{
		typeOkay = YES;
	}
	
	if(!typeOkay) return nil;
	
	if(tokens.count == 2)
	{
		[parsed addObject:tokens[0]];
		int pos = [tokens[1] intValue];
		if(pos == INT_MIN || pos == INT_MAX) return nil;
		if(pos > 0 && [tokens[0] isEqualToString:A4RequestKeyStringSettings]) return nil;
		[parsed addObject:tokens[1]];
		return parsed;
	}
	if(tokens.count == 3 && [tokens[0] isEqualToString:A4RequestKeyStringSound])
	{
		[parsed addObject:tokens[0]];
		if(![tokens[1] isEqualToString:@"x"]) return nil;
		[parsed addObject:tokens[1]];
		int trk = [tokens[2] intValue];
		if(trk > 3) return nil;
		[parsed addObject:tokens[2]];
		return parsed;
	}
	return nil;
}

- (void) dispatchErrorHandlerForTransaction:(A4Transaction *)t withError:(NSError *)err
{
	dispatch_async(t.completionQueue, ^{
		
//		DLog(@"calling error handler");
		t.errorHandler(err);
//		DLog(@"done");
	});
}

- (void) cancelCurrentTransactionWithError:(NSError *)err
{
	[self stopListeningForSysex];
	[self dispatchErrorHandlerForTransaction:self.currentTransaction withError:err];
	self.currentTransaction = nil;
	[self dequeue];
}

- (void) completeCurrentTransaction
{
	[self stopListeningForSysex];
	[self cancelTimeout];
//	DLog(@"completing transaction..");
	A4Transaction *t = _currentTransaction;
	_currentTransaction = nil;
	
	dispatch_async(t.completionQueue, ^{
		
//		DLog(@"calling completionHandler on completion queue..");
		t.completionHandler(t.completedSubRequests);
//		DLog(@"done");
		
	});
	
	if(self.queue.count)
	{
//		DLog(@"dequeuing next transaction");
		[self dequeue];
	}
	else
	{
//		DLog(@"all done");
	}
}


- (void) addTransactionToQueueTail:(A4Transaction *)transaction
{
	if(![_queue containsObject:transaction])
	{
//		DLog(@"adding transaction to tail");
		[_queue addObject:transaction];
	}
}

- (void) addTransactionToQueueHead:(A4Transaction *)transaction
{
	if(![_queue containsObject:transaction])
	{
		
//		DLog(@"adding transaction to head");
		[_queue insertObject:transaction atIndex:0];
	}
}

- (void) removeTransactionFromQueue:(A4Transaction *)transaction
{
	if([_queue containsObject:transaction])
	{
//		DLog(@"removing transaction from queue");
		[ _queue removeObject:transaction];
	}
}

- (void) stopListeningForSysex
{
	if(!_isListeningForSysex) return;
//	DLog(@"stop listening");
	_isListeningForSysex = NO;
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kA4SysexNotification object:nil];
}

- (void) startListeningForSysex
{
	if(_isListeningForSysex) return;
//	DLog(@"start listening");
	_isListeningForSysex = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syx:) name:kA4SysexNotification object:nil];
}

- (BOOL) currentTransactionContainsKey:(Key) key
{
	return [self array:self.currentTransaction.keysToProcess containsKey:key];
}

- (BOOL) array:(NSArray *)array containsKey:(Key)key
{
	for (NSValue *keyVal in array)
	{
		Key k = keyVal.keyValue;
		if(KeysAreEqual(key, k)) return YES;
	}
	
	return NO;
}

- (void) checkIfCurrentTransactionIsDone
{
	if(self.currentTransaction)
	{
		if(! self.currentTransaction.keysToProcess.count)
		{
			[self addAdditionalKeysToCurrentTransaction];
		}
		
		if(self.currentTransaction.options & A4RequestOptions_SAFER_ &&
		   self.currentTransaction.keysToProcess.count)
		{
			[self processFirstKeyInCurrentTransaction];
		}
	}
}

- (void) addAdditionalKeysToCurrentTransaction
{
	if(self.currentTransactionKeysAddedDuringRequest.count)
	{
		for (NSValue *val in self.currentTransactionKeysAddedDuringRequest)
		{
			Key key = val.keyValue;
			
			if( ! [self array:self.totalKeysForCurrentTransaction containsKey:key])
			{
				[A4Request addKey:key toKeysArray:self.currentTransaction.keysToProcess];
			}
		}
		[self.currentTransactionKeysAddedDuringRequest removeAllObjects];
		if(self.currentTransaction.keysToProcess.count)
		{
			[self.totalKeysForCurrentTransaction addObjectsFromArray:self.currentTransaction.keysToProcess];
			if(self.currentTransaction.options & A4RequestOptions_SAFER_)
			{
				[self addCurrentKeysToTotalByteCount];
				[self processFirstKeyInCurrentTransaction];
			}
			else
			{
				[self processKeysInCurrentTransaction];
			}
		}
	}
	else
	{
		[self completeCurrentTransaction];
	}
}


- (void) currentTransactionAddReceivedObject:(A4SysexMessage *)message temp:(BOOL)temp
{
	if(!self.currentTransaction) return;
	
	if(! (self.currentTransaction.options & A4RequestOptions_SAFER_) && !message)
	{
		[self cancelCurrentTransactionWithError:[NSError errorWithDomain:@"failed sysex receive" code:-1 userInfo:nil]];
		return;
	}
	else if (! message)
	{
		[self processFirstKeyInCurrentTransaction];
		return;
	}
	
	Key key;
	if(temp)
	{
		if(message.type == A4SysexMessageID_Sound)
		{
			key = KeyMakeActiveSound(A4SysexRequestIDForResponseID(message.type + 6), A4NULL, message.position);
		}
		else
		{
			key = KeyMake(A4SysexRequestIDForResponseID(message.type + 6), A4NULL);
		}
	}
	else
	{
		key = KeyMake(A4SysexRequestIDForResponseID(message.type), message.position);
	}
	
	if([self currentTransactionContainsKey:key])
	{
		if([message isKindOfClass:[A4Pattern class]])
		{
			A4Pattern *pattern = (A4Pattern *) message;
			if(self.currentTransaction.options & A4RequestOptionsPatternsWithKits)
			{
				if( ! [pattern isDefaultPattern])
				{
					Key key = KeyMake(A4SysexRequestID_Kit, pattern.kit);
					[self addKeyToCurrentTransaction:key];
				}
			}
			
			if(self.currentTransaction.options == A4RequestOptionsPatternsWithLockedSounds)
			{
				if( ! [pattern isDefaultPattern])
				{
					NSArray *soundLocks = [pattern soundLocks];
					for (NSNumber *n in soundLocks)
					{
						if( ! [pattern isDefaultPattern])
						{
							Key key = KeyMake(A4SysexRequestID_Sound, n.intValue);
							[self addKeyToCurrentTransaction:key];
						}
					}
				}
			}
		}
		
		NSMutableArray *remove = @[].mutableCopy;
		
		for (NSValue *val in self.currentTransaction.keysToProcess)
		{
			Key k = val.keyValue;
			if(KeysAreEqual(k, key)) [remove addObject:val];
		}
		if(remove.count)
		{
			[self.currentTransaction.keysToProcess removeObjectsInArray:remove];
			[self.currentTransaction.completedSubRequests setObject:message forKey:[A4Request keyStringWithKey:key]];
			
			self.currentTransaction.completedPayloadByteCount += message.payloadLength;
			
			if([self.currentTransaction.delegate respondsToSelector:@selector(a4requestWithHandle:didUpdateProgress:)])
			{
				double progress = 1;
				if(self.currentTransaction.totalPayloadByteCount > 0)
				{
					progress = self.currentTransaction.completedPayloadByteCount / (double) self.currentTransaction.totalPayloadByteCount;
				}
				
				dispatch_async(self.currentTransaction.completionQueue, ^{
					
					[self.currentTransaction.delegate a4requestWithHandle:self.currentTransaction.ident didUpdateProgress:progress];
					
				});
			}
		}
	}
}

- (void) syx:(NSNotification *)n
{
	@synchronized(self)
	{
		if(!self.currentTransaction) return;
		if(!self.currentTransaction.keysToProcess) return;
		
		NSData *d = n.object;
		
		if(d.length < 0x07) return;
		const uint8_t *bytes = d.bytes;
		
		//	DLog(@"got syx with ID: 0x%X", bytes[0x06]);
		
		switch (bytes[0x06])
		{
			case A4SysexMessageID_Kit:
			{
				A4Kit *kit = [A4Kit messageWithSysexData:d];
				[self currentTransactionAddReceivedObject:kit temp:NO];
				break;
			}
			case A4SysexMessageID_Pattern:
			{
				A4Pattern *pattern = [A4Pattern messageWithSysexData:d];
				[self currentTransactionAddReceivedObject:pattern temp:NO];
				break;
			}
			case A4SysexMessageID_Sound:
			{
				//			DLog(@"sound ID");
				A4Sound *sound = [A4Sound messageWithSysexData:d];
				[self currentTransactionAddReceivedObject:sound temp:NO];
				break;
			}
			case A4SysexMessageID_Global:
			{
				A4Global *global = [A4Global messageWithSysexData:d];
				[self currentTransactionAddReceivedObject:global temp:NO];
				break;
			}
			case A4SysexMessageID_Song:
			{
				A4Song *song = [A4Song messageWithSysexData:d];
				[self currentTransactionAddReceivedObject:song temp:NO];
				break;
			}
			case A4SysexMessageID_Settings:
			{
				A4Settings *settings = [A4Settings messageWithSysexData:d];
				[self currentTransactionAddReceivedObject:settings temp:NO];
				break;
			}
				
			case A4SysexMessageID_Kit_X:
			{
				A4Kit *kit = [A4Kit messageWithSysexData:d];
				[self currentTransactionAddReceivedObject:kit temp:YES];
				break;
			}
			case A4SysexMessageID_Pattern_X:
			{
				A4Pattern *pattern = [A4Pattern messageWithSysexData:d];
				[self currentTransactionAddReceivedObject:pattern temp:YES];
				break;
			}
			case A4SysexMessageID_Sound_X:
			{
				A4Sound *sound = [A4Sound messageWithSysexData:d];
				[self currentTransactionAddReceivedObject:sound temp:YES];
				break;
			}
			case A4SysexMessageID_Global_X:
			{
				A4Global *global = [A4Global messageWithSysexData:d];
				[self currentTransactionAddReceivedObject:global temp:YES];
				break;
			}
			case A4SysexMessageID_Song_X:
			{
				A4Song *song = [A4Song messageWithSysexData:d];
				[self currentTransactionAddReceivedObject:song temp:YES];
				break;
			}
			case A4SysexMessageID_Settings_X:
			{
				A4Settings *settings = [A4Settings messageWithSysexData:d];
				[self currentTransactionAddReceivedObject:settings temp:YES];
				break;
			}
				
			default: break;
		}
		
		[self checkIfCurrentTransactionIsDone];
	}
}


@end
