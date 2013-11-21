//
//  MDMath.h
//  MachineDrumFramework
//
//  Created by Jakob Penca on 9/25/13.
//  Copyright (c) 2013 Jakob Penca. All rights reserved.
//



#import <stdlib.h>
#import <math.h>
#import <stdint.h>

#pragma once

static double mdmath_gaussRand()
{
	static double V1, V2, S;
	static int phase = 0;
	double X;
	
	if(phase == 0) {
		do {
			double U1 = (double)arc4random_uniform(UINT32_MAX) / (double) (UINT32_MAX-1);
			double U2 = (double)arc4random_uniform(UINT32_MAX) / (double) (UINT32_MAX-1);
			
			V1 = 2 * U1 - 1;
			V2 = 2 * U2 - 1;
			S = V1 * V1 + V2 * V2;
		} while(S >= 1 || S == 0);
		
		X = V1 * sqrt(-2 * log(S) / S);
	} else
		X = V2 * sqrt(-2 * log(S) / S);
	
	phase = 1 - phase;
	
	return X;
}

static float mdmath_gaussRandf()
{
	static float V1, V2, S;
	static int phase = 0;
	float X;
	
	if(phase == 0) {
		do {
			float U1 = (float)arc4random_uniform(UINT32_MAX) / (float) (UINT32_MAX-1);
			float U2 = (float)arc4random_uniform(UINT32_MAX) / (float) (UINT32_MAX-1);
			
			V1 = 2 * U1 - 1;
			V2 = 2 * U2 - 1;
			S = V1 * V1 + V2 * V2;
		} while(S >= 1 || S == 0);
		
		X = V1 * sqrt(-2 * log(S) / S);
	} else
		X = V2 * sqrt(-2 * log(S) / S);
	
	phase = 1 - phase;
	
	return X;
}

double mdmath_clamp(double x, double a, double b);
double mdmath_map(double value, double istart, double istop, double ostart, double ostop);
double mdmath_rand(double min, double max);
long mdmath_randi(long min, long max);

float mdmath_clampf(float x, float a, float b);
float mdmath_mapf(float value, float istart, float istop, float ostart, float ostop);
float mdmath_randf(float min, float max);

long mdmath_wrap(long kX, long const kLowerBound, long const kUpperBound);