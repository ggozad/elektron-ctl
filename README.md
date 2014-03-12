A framework for iOS/OSX which enables deep MIDI control of the Elektron Machinedrum & Analog Four synthesizers.

as of today, undocumented.

some examples:

```[A4Request requestWithKeys:@[@"pat.x"]
			 completionHandler:^(NSDictionary *dict) {
				 
				 A4Pattern *pattern = dict[@"pat.x"];
				 for(int trackIndex = 0; trackIndex < 4; trackIndex++)
				 {
					 int trackLength = pattern.masterLength;
					 if(pattern.timeMode == A4PatternTimeModeAdvanced)
					 {
						 trackLength = [pattern track:trackIndex].settings->trackLength;
					 }
					 
					 for (int stepIndex = 0; stepIndex < trackLength; stepIndex++)
					 {
						 A4Trig trig = [[pattern track:trackIndex] trigAtStep:stepIndex];
						 if(trig.flags & A4TRIGFLAGS.TRIG && trig.soundLock != A4NULL)
						 {
							 trig.soundLock = mdmath_rand(0, 127);
							 [pattern setTrig:trig atStep:stepIndex inTrack:trackIndex];
						 }
					 }
				 }
				 
				 [pattern sendTemp];
				 
			 } errorHandler:^(NSError *err) {
				 
				 NSLog(@"meh: %@", err);
				 
			 }];