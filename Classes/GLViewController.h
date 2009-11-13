//
//  GLViewController.h
//  HelloTeapot
//
//  Created by turner on 5/26/09.
//  Copyright Douglass Turner Consulting 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "VectorMatrix.h"
#import "GLView.h"

@class BoundingBox;
@interface GLViewController : UIViewController  <GLViewDelegate> {
	
	BoundingBox		*_bbox;
	M3DMatrix44f	_cameraTransform;
	M3DMatrix44f	_openGLCameraInverseTransform;
}

@property (nonatomic, retain) BoundingBox	*bbox;

- (void)placeCameraAtLocation:(M3DVector3f)location 
					   target:(M3DVector3f)target 
						   up:(M3DVector3f)up;

- (void)perspectiveProjectionWithFieldOfViewY:(GLfloat)fieldOfViewY 
				   aspectRatioWidthOverHeight:(GLfloat)aspectRatioWidthOverHeight 
										 near:(GLfloat)near 
										  far:(GLfloat)far;

- (void) doTeapotBoundingBox:(BoundingBox *)b;
- (void) teapotBoundingBox;

- (void) drawView:(GLView*)view;
- (void)setupView:(GLView*)view;

@end
