//
//  BoundingBox.h
//  HelloOpenGL
//
//  Created by turner on 4/30/09.
//  Copyright 2009 Douglass Turner Consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>

@interface BoundingBox : NSObject {
	
	GLfloat minX;
	GLfloat minY;
	GLfloat minZ;
	
	GLfloat cX;
	GLfloat cY;
	GLfloat cZ;
	
	GLfloat maxX;
	GLfloat maxY;
	GLfloat maxZ;
	
}

@property(assign) GLfloat minX;
@property(assign) GLfloat minY;
@property(assign) GLfloat minZ;

@property(assign) GLfloat cX;
@property(assign) GLfloat cY;
@property(assign) GLfloat cZ;

@property(assign) GLfloat maxX;
@property(assign) GLfloat maxY;
@property(assign) GLfloat maxZ;

- (id)init;

- (void)calculateCentroid;

@end
