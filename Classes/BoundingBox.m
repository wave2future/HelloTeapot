//
//  BoundingBox.m
//  HelloOpenGL
//
//  Created by turner on 4/30/09.
//  Copyright 2009 Douglass Turner Consulting. All rights reserved.
//

#import "BoundingBox.h"

@implementation BoundingBox

@synthesize minX;
@synthesize minY;
@synthesize minZ;

@synthesize cX;
@synthesize cY;
@synthesize cZ;

@synthesize maxX;
@synthesize maxY;
@synthesize maxZ;

- (id)init {
	
	self = [super init];
	
	if(nil != self) {
		self.minX	= self.minY	= self.minZ	= NAN;
		self.maxX	= self.maxY = self.maxZ	= NAN;
		self.cX		= self.cY	= self.cZ	= NAN;
	}
	
	return self;
	
}

- (void)calculateCentroid {
	
	self.cX = (self.maxX + self.minX) / 2.0;
	self.cY = (self.maxY + self.minY) / 2.0;
	self.cZ = (self.maxZ + self.minZ) / 2.0;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Bounding Box is size(%f %f %f) min(%f %f %f) center(%f %f %f) max(%f %f %f)", 
			self.maxX - self.minX,
			self.maxY - self.minY,
			self.maxZ - self.minZ,
			
			self.minX,
			self.minY,
			self.minZ,
			
			self.cX,
			self.cY,
			self.cZ,
			
			self.maxX,
			self.maxY,
			self.maxZ];
}

@end