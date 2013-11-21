//
//  A4PVal.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/2/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#pragma once
#import <stdint.h>
#import <MacTypes.h>
#import "A4Params.h"

typedef struct A4PVal
{
	A4Param param;
	uint8_t coarse;
	int8_t fine;
}
A4PVal;

A4PVal A4PValMakeInvalid();
A4PVal A4PValMin(A4Param param);
A4PVal A4PValMax(A4Param param);
A4PVal A4PValCentered(A4Param param);
A4PVal A4PValSanitizeClamp(A4PVal val);
A4PVal A4PValSanitizeWrap(A4PVal val);
A4PVal A4PValMakeClear(A4Param param);
A4PVal A4PValMake8(A4Param param, uint8_t coarse);
A4PVal A4PValMake16(A4Param param, uint8_t coarse, int8_t fine);
A4PVal A4PValMake(A4Param param, double val);
A4PVal A4PValMakeNormalized(A4Param param, double normalizedDoubleValue);
A4PVal A4PValTranslateForLock(A4PVal val);
A4PVal A4PValTranslateForSound(A4PVal val);
double A4PValDoubleVal(A4PVal val);
double A4PValDoubleValNormalized(A4PVal lockValue);

A4PVal A4PValFxMin(A4Param param);
A4PVal A4PValFxMax(A4Param param);
A4PVal A4PValFxCentered(A4Param param);
A4PVal A4PValFxSanitizeClamp(A4PVal val);
A4PVal A4PValFxSanitizeWrap(A4PVal val);
A4PVal A4PValFxMake8(A4Param param, uint8_t coarse);
A4PVal A4PValFxMake16(A4Param param, uint8_t coarse, int8_t fine);
A4PVal A4PValFxMake(A4Param param, double val);
A4PVal A4PValFxMakeNormalized(A4Param param, double normalizedDoubleValue);
double A4PValFxDoubleVal(A4PVal val);
double A4PValFxDoubleValNormalized(A4PVal lockValue);