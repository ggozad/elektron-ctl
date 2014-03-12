//
//  MDMath.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/16/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//

#import "MDMath.h"


double mdmath_clamp(double x, double a, double b)
{
	if(a > b) {	double tmp = a; a = b; b = tmp; }
	return x < a ? a : (x > b ? b : x);
}

double mdmath_map(double value, double istart, double istop, double ostart, double ostop)
{
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

double mdmath_map_clamp(double value, double istart, double istop, double ostart, double ostop)
{
	value = mdmath_map(value, istart, istop, ostart, ostop);
	return mdmath_clamp(value, ostart, ostop);
}

float mdmath_clampf(float x, float a, float b)
{
	if(a > b) {	double tmp = a; a = b; b = tmp; }
	return x < a ? a : (x > b ? b : x);
}

float mdmath_mapf(float value, float istart, float istop, float ostart, float ostop)
{
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

float mdmath_mapf_clamp(float value, float istart, float istop, float ostart, float ostop)
{
	value = mdmath_mapf(value, istart, istop, ostart, ostop);
	return mdmath_clampf(value, ostart, ostop);
}

long mdmath_wrap(long kX, long const kLowerBound, long const kUpperBound)
{
    long range_size = kUpperBound - kLowerBound + 1;
	
    if (kX < kLowerBound)
        kX += range_size * ((kLowerBound - kX) / range_size + 1);
	
    return kLowerBound + (kX - kLowerBound) % range_size;
}

double mdmath_rand(double min, double max)
{
	if(max == min) return max;
	if(min > max)
	{
		double t = max; max = min; min = t;
	}
	return mdmath_map(arc4random_uniform(UINT32_MAX), 0, UINT32_MAX-1, min, max);
}

long mdmath_randi(long min, long max)
{
	if(max == min) return max;
	if(min > max)
	{
		long t = max; max = min; min = t;
	}
	unsigned long delta = max - min;
	return min + arc4random_uniform(delta+1);
}


