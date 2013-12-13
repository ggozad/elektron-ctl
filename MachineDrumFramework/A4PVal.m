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

A4PVal A4PValSanitizeClamp(A4PVal val)
{
	if(val.param == 0xFF) return A4PValMakeInvalid();
	if(val.value == A4NULL) return A4PValMakeInvalid();
	val.value = mdmath_clamp(val.value, A4ParamMin(val.param), A4ParamMaxi(val.param));
	return val;
}

A4PVal A4PValSanitizeWrap(A4PVal val)
{
	if(val.param == (uint8_t)A4NULL) return A4PValMakeInvalid();
	if(val.value == A4NULL) return A4PValMakeInvalid();
	val.value = mdmath_wrap(val.value, A4ParamMin(val.param), A4ParamMaxi(val.param));
	return val;
}


A4PVal A4PValMakeInvalid()
{
	A4PVal lock;
	lock.param = A4NULL;
	lock.value = A4NULL;
	return lock;
}

A4PVal A4PValMakeClear(A4Param param)
{
	A4PVal lock;
	lock.param = param;
	lock.value = A4NULL;
	return lock;
}

A4PVal A4PValMakeI(A4Param param, int16_t value)
{
	A4PVal lock;
	lock.param = param;
	lock.value = value;
	return lock;
}

/*
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
*/


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
		lockVal.value = dst;
		return lockVal;
	}
	
	doubleValue = mdmath_clamp(doubleValue, A4ParamMin(param), A4ParamMax(param));
	
	if(A4ParamIs16Bit(param))
	{
		int16_t i = mdmath_map(doubleValue, 0, 127.5, 0, A4PARAM_16BIT_MAX);
		lockVal.value = i;
	}
	else
	{
		lockVal.value = (uint8_t) doubleValue;
	}
	return lockVal;
}

double A4PValDoubleVal(A4PVal lock)
{
	if(lock.param == A4NULL || lock.value == A4NULL) return A4NULL;
	
	if(A4ParamIsModulatorDestination(lock.param))
	{
		uint8_t idx = A4ParamIndexOfModTargetInModSource(lock.value, lock.param);
		if(idx == A4NULL) return A4NULL;
		uint8_t len = A4ParamModTargetCountInModSource(lock.param);
		return mdmath_map(idx, 0, len-1, 0, 128);
	}
	else if(A4ParamIs16Bit(lock.param))
	{
		return mdmath_map(lock.value, 0, A4PARAM_16BIT_MAX, 0, 127.5);
	}
	else
	{
		return lock.value;
	}
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
		int idx = A4ParamIndexOfModTargetInModSource(lock.value, lock.param);
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
	// TODO: do this
//	if(val.fine == (int8_t)A4NULL) return val;
//	val.fine = (val.fine >> 1) & 0x7F;
	return val;
}

A4PVal A4PValTranslateForSound(A4PVal val)
{
	// TODO: do this
//	if(val.fine == (int8_t)A4NULL) return val;
//	val.fine = (val.fine << 1) & 0xFE;
	return val;
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