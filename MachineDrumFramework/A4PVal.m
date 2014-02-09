//
//  A4PVal.c
//  MachineDrumFramework
//
//  Created by Jakob Penca on 10/2/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//


#import "A4PVal.h"
#import "MDMath.h"

#define INT16_MAX_MINUS_ONE (INT16_MAX - 1)
#define A4PARAM_16BIT_MAX 32638
#define A4PARAM_16BIT_MIN 128

A4PVal A4PValSanitizeClamp(A4PVal val)
{
	if(val.param == 0xFF) return A4PValMakeInvalid();
	if(val.coarse == A4NULL) return A4PValMakeInvalid();
	double doubleVal = A4PValDoubleVal(val);
	val = A4PValMake(val.param, doubleVal);
	return val;
}

A4PVal A4PValSanitizeWrap(A4PVal val)
{
	if(val.param == (uint8_t)A4NULL) return A4PValMakeInvalid();
	if(val.coarse == A4NULL) return A4PValMakeInvalid();
	val.coarse = mdmath_wrap(val.coarse, A4ParamMin(val.param), A4ParamMax(val.param));
	return val;
}


A4PVal A4PValMakeInvalid()
{
	A4PVal lock;
	lock.param = A4NULL;
	lock.coarse = A4NULL;
	lock.fine = A4NULL;
	return lock;
}

A4PVal A4PValMakeClear(A4Param param)
{
	A4PVal lock;
	lock.param = param;
	lock.coarse = A4NULL;
	lock.fine = A4NULL;
	return lock;
}


A4PVal A4PValMake8(A4Param param, uint8_t coarse)
{
	A4PVal lockVal;
	lockVal.param = param;
	lockVal.coarse = coarse;
	lockVal.fine = 0;
	return A4PValSanitizeClamp(lockVal);
}

A4PVal A4PValMake16(A4Param param, uint8_t coarse, int8_t fine)
{
	A4PVal lockVal;
	lockVal.param = param;
	lockVal.coarse = coarse;
	lockVal.fine = fine;
	return A4PValSanitizeClamp(lockVal);
}

A4PVal A4PValMin(A4Param param)
{
	return A4PValMakeNormalized(param, 0);
}

A4PVal A4PValMax(A4Param param)
{
	return A4PValMakeNormalized(param, 1);
}

A4PVal A4PValCentered(A4Param param)
{
	return A4PValMakeNormalized(param, .5);
}

A4PVal A4PValMake(A4Param param, double doubleValue)
{
	A4PVal lockVal;
	lockVal.param = param;
	
	if(A4ParamIsModulatorDestination(param))
	{
		uint8_t count = A4ParamModTargetCountInModSource(param);
		doubleValue = mdmath_map(doubleValue, 0, 128, 0, count-1);
		doubleValue = mdmath_clamp(doubleValue, 0, count-1);
		A4Param dst = A4ParamModTargetByIndexInModSource(doubleValue, param);
		if(dst == A4NULL)
		{
			return A4PValMakeInvalid();
		}
		lockVal.coarse = dst;
		lockVal.fine = 0;
		return lockVal;
	}
	
	doubleValue = mdmath_clamp(doubleValue, A4ParamMin(param), A4ParamMax(param));
	
	if(A4ParamIs16Bit(param))
	{
		int16_t i = mdmath_map(doubleValue, 0, 128, A4PARAM_16BIT_MIN, A4PARAM_16BIT_MAX);
		CFSwapInt16HostToBig(i);
		lockVal.coarse = i >> 8;
		lockVal.fine = i & 0xFF;
	}
	else
	{
		lockVal.coarse = (uint8_t) doubleValue;
		lockVal.fine = 0;
	}
	return lockVal;
}

double A4PValDoubleVal(A4PVal lock)
{
	if(lock.param == A4NULL || lock.coarse == A4NULL) return A4NULL;
	
	if(A4ParamIsModulatorDestination(lock.param))
	{
		uint8_t idx = A4ParamIndexOfModTargetInModSource(lock.coarse, lock.param);
		if(idx == A4NULL) return A4NULL;
		uint8_t len = A4ParamModTargetCountInModSource(lock.param);
		return mdmath_map(idx, 0, len-1, 0, 128);
	}
	else if(A4ParamIs16Bit(lock.param))
	{
		int16_t i = lock.coarse | lock.fine << 8;
		i = CFSwapInt16BigToHost(i);
		return mdmath_map(i, A4PARAM_16BIT_MIN, A4PARAM_16BIT_MAX, 0, 128);
	}
	else
	{
		return lock.coarse;
	}
}

int16_t A4PValIntVal(A4PVal lockValue)
{
	int16_t intval = CFSwapInt16BigToHost(lockValue.coarse | lockValue.fine << 8);
	return intval;
}

A4PVal A4PValMakeI(A4Param param, int16_t value)
{
	A4PVal pval;
	pval.param = param;
	value = CFSwapInt16HostToBig(value);
	BOOL is16Bit = A4ParamIs16Bit(param);
	pval.coarse = value & 0xFF;
	if(!is16Bit) pval.coarse = MIN(pval.coarse, A4ParamMax(param));
	pval.fine = is16Bit ? (value >> 8) & 0xFF : 0;
	return pval;
}

A4PVal A4PValMakeNormalized(A4Param param, double normalizedDoubleValue)
{
	normalizedDoubleValue = mdmath_clamp(normalizedDoubleValue, 0, 1);
	double doubleVal;
	if(A4ParamIsModulatorDestination(param))
	{
		int len = A4ParamModTargetCountInModSource(param);
		if(len <= 1) return A4PValMakeInvalid();
		doubleVal = mdmath_map(normalizedDoubleValue, 0, 1, 0, len-1);
	}
	else
		doubleVal = mdmath_map(normalizedDoubleValue, 0, 1, A4ParamMin(param), A4ParamMax(param));
	
	return A4PValMake(param, doubleVal);
}



double A4PValDoubleValNormalized(A4PVal lock)
{
	if(A4ParamIsModulatorDestination(lock.param))
	{
		int idx = A4ParamIndexOfModTargetInModSource(lock.coarse, lock.param);
		int len = A4ParamModTargetCountInModSource(lock.param);
		if(idx == A4NULL || len <= 1 || len == A4NULL) return -1;
		double doubleVal = mdmath_map(idx, 0, len-1, 0, 1);
		return mdmath_clamp(doubleVal, 0, 1);
	}
	
	double val = A4PValDoubleVal(lock);
	return mdmath_clamp( mdmath_map(val, A4ParamMin(lock.param), A4ParamMax(lock.param), 0, 1), 0, 1);
}

A4PVal A4PValTranslateForLock(A4PVal val)
{
	if(val.fine == (int8_t)A4NULL) return val;
	val.fine /= 2;
	return val;
}

A4PVal A4PValTranslateForSound(A4PVal val)
{
	if(val.fine == (int8_t)A4NULL) return val;
	val.fine *= 2;
	return val;
}


A4PVal A4PValFxMake16(A4Param param, uint8_t coarse, int8_t fine)
{
	A4PVal pval;
	pval.param = param;
	pval.coarse = coarse;
	pval.fine = fine;
	return pval;
}



A4PVal A4PValFxMakeI(A4Param param, int16_t value)
{
	A4PVal pval;
	pval.param = param;
	value = CFSwapInt16HostToBig(value);
	pval.coarse = value & 0xFF;
	BOOL is16Bit = A4ParamFxIs16Bit(param);
	if(! is16Bit)
	{
		pval.coarse = MIN(pval.coarse, A4ParamFxMax(param));
	}
	pval.fine =  is16Bit ? (value >> 8) & 0xFF : 0;
	return pval;
}


int16_t A4PValFxIntVal(A4PVal lockValue)
{
	int16_t intval = CFSwapInt16BigToHost(lockValue.coarse | lockValue.fine << 8);
	return intval;
}


/*
A4PVal A4PValFxMin(A4Param param)
{
	return A4PValFxMakeNormalized(param, 0);
}

A4PVal A4PValFxMax(A4Param param)
{
	return A4PValFxMakeNormalized(param, 1);
}

A4PVal A4PValFxCentered(A4Param param)
{
	return A4PValFxMakeNormalized(param, .5);
}

A4PVal A4PValFxSanitizeClamp(A4PVal val)
{
	if(val.param == 0xFF) return A4PValMakeInvalid();
	if(val.coarse == 0xFF || val.fine == (int8_t)A4NULL) return A4PValMakeInvalid();
	val.coarse = mdmath_clamp(val.coarse, A4ParamFxMin(val.param), A4ParamFxMax(val.param));
	return val;
}

A4PVal A4PValFxSanitizeWrap(A4PVal val)
{
	if(val.param == 0xFF) return A4PValMakeInvalid();
	if(val.coarse == 0xFF || val.fine == (int8_t)A4NULL) return A4PValMakeInvalid();
	val.coarse = mdmath_wrap(val.coarse, A4ParamFxMin(val.param), A4ParamFxMax(val.param));
	return val;
}

A4PVal A4PValFxMake(A4Param param, double doubleValue)
{
	A4PVal lockVal;
	lockVal.param = param;
	
	
	if(A4ParamFxIs16Bit(param))
	{
		lockVal.coarse = doubleValue;
		double fraction = doubleValue - round(doubleValue);
		int8_t fine = mdmath_map(fraction, -1, 1, INT8_MIN, INT8_MAX);
		lockVal.fine = fine * 2;
	}
	else
	{
		lockVal.coarse = (uint8_t) doubleValue;
		lockVal.fine = 0;
	}
	return A4PValFxSanitizeClamp(lockVal);
}

A4PVal A4PValFxMake8(A4Param param, uint8_t coarse)
{
	A4PVal lockVal;
	lockVal.param = param;
	lockVal.coarse = coarse;
	lockVal.fine = 0;
	return A4PValFxSanitizeClamp(lockVal);
}

A4PVal A4PValFxMake16(A4Param param, uint8_t coarse, int8_t fine)
{
	A4PVal lockVal;
	lockVal.param = param;
	lockVal.coarse = coarse;
	lockVal.fine = fine;
	return A4PValFxSanitizeClamp(lockVal);
}


A4PVal A4PValFxMakeNormalized(A4Param param, double normalizedDoubleValue)
{
	normalizedDoubleValue = mdmath_clamp(normalizedDoubleValue, 0, 1);
	double val = mdmath_map(normalizedDoubleValue, 0, 1, A4ParamFxMin(param), A4ParamFxMax(param));
	return A4PValFxMake(param, val);
}

double A4PValFxDoubleVal(A4PVal lockValue)
{
	if(lockValue.param == 0xFF || lockValue.coarse == 0xFF || lockValue.fine == (int8_t)A4NULL) return -1;
	
	if(A4ParamFxIs16Bit(lockValue.param))
	{
		int8_t fine = lockValue.fine / 2;
		double frac = mdmath_map(fine, INT8_MIN, INT8_MAX, -1, 1);
		return lockValue.coarse + frac;
	}
	else
	{
		return lockValue.coarse;
	}
}

double A4PValFxDoubleValNormalized(A4PVal lockValue)
{
	double val = A4PValFxDoubleVal(lockValue);
	return mdmath_map(val, A4ParamFxMin(lockValue.param), A4ParamFxMax(lockValue.param), 0, 1);
	return mdmath_clamp(val, 0, 1);
}
*/